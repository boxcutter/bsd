#!/bin/sh
# Id: autoinst.sh,v 1.22 2014/12/02 20:21:17 asau Stab
# Last update: Nov 23 2015
#
# Adapted for Packer/Vagrant from
# https://mail-index.netbsd.org/netbsd-users/2015/10/05/msg017003.html
#
set -e

_progname="${0##*/}"
usage="usage: ${0##*/} [-s swap-size-mb] [-S swap-size-blocks] [-r root-password (need to have pwhash(1) or pass precomputed string)] [-c console-type] [-C console-speed] [-h host-name] [-i network-if] [-p] device-name"

# You may want to run `gpt destroy ${SD}', otherwise this script won't work properly

SWAPSIZE=
PASSWD=
SERIAL=pc
SERIALSPEED=0
HOSTNAME=netbsd
PKGSRC=
IFDEV=wm0
while getopts "c:C:h:pr:s:S:i:" opt; do
    case $opt in
        c) SERIAL="${OPTARG}";;
        C) SERIALSPEED="${OPTARG}";;
        h) HOSTNAME="${OPTARG}";;
        p) PKGSRC=YES;;
        r) PASSWD="$(pwhash ${OPTARG} 1>/dev/null 2>/dev/null || echo ${OPTARG})";;
        s) SWAPSIZE=$((2 "*" 1024 "*" ${OPTARG}));; # swap size in MiB
        S) SWAPSIZE=$((0 + ${OPTARG}));;
        h) IFDEV="${OPTARG}";;
        \?) echo "$usage" 1>&2; exit 1;;
    esac
done
shift $(expr $OPTIND - 1)

if [ $# != 1 ]; then echo "$usage" 1>&2; exit 1; fi

SD="$1"

# Apply defaults:
: ${SD:?device name is empty}
: ${SWAPSIZE:=$((2 "*" 1024 "*" 16))} # default to 16 MiB

# Path to installation sets:
: ${TMPDIR:=/tmp} # temporary directory
: ${SETSDIR:=/amd64/binary/sets}

echo "Disk paritioning"
# Disk partitioning
gpt create -f ${SD}

echo "Unallocated space limits"
# Unallocated space limits:
LIMITS="$(gpt show ${SD} | grep '^[[:space:]]\+[[:digit:]]\+[[:space:]]\+[[:digit:]]\+[[:space:]]\+$' | while read x ; do echo $x ; done )"
START="${LIMITS%% *}" # first number
SIZE="${LIMITS##* }" # second number

# Align:
ALIGN=64 # assume it is always greater than START (usually 34)
SIZE=$((${SIZE} - (${ALIGN} - ${START})))
START=${ALIGN}

# Root partition limits:
ROOTSTART=${START}
ROOTSIZE=$((${SIZE} - ${SWAPSIZE}))
ROOTSIZE=$((${ROOTSIZE} / ${ALIGN} * ${ALIGN})) # align

SWAPSTART=$((${ROOTSTART} + ${ROOTSIZE})) # aligned due to ROOTSTART and ROOTSIZE both aligned
# SWAPSIZE is defined already

echo "Generating partition labels"
# Generate partition labels:
ROOT_LABEL="root-$(dd if=/dev/urandom cbs=1 conv=unblock | grep -a '[:alnum:]' | (x=; for i in 1 2 3 4 5 6; do read ch; x="$x$ch"; done; echo "$x"))"
SWAP_LABEL="swap-$(dd if=/dev/urandom cbs=1 conv=unblock | grep -a '[:alnum:]' | (x=; for i in 1 2 3 4 5 6; do read ch; x="$x$ch"; done; echo "$x"))"

echo "Create partitions"
# Create partitions:
gpt add -i 1 -t  ffs -l "${ROOT_LABEL}" -b ${ROOTSTART} -s ${ROOTSIZE} ${SD}
gpt add -i 2 -t swap -l "${SWAP_LABEL}" -b ${SWAPSTART} -s ${SWAPSIZE} ${SD}
dkctl ${SD} makewedges

ROOT="$(dkctl ${SD} listwedges | grep "${ROOT_LABEL}" | sed 's!^\([^:]*\):.*!\1!')"
SWAP="$(dkctl ${SD} listwedges | grep "${SWAP_LABEL}" | sed 's!^\([^:]*\):.*!\1!')"

echo "Make it bootable"
# Make it bootable
gpt biosboot -i 1 ${SD}

mnt=${TMPDIR}/${_progname}.$$

echo "Now create filesystems"
# Now create filesystems, and unpack sets
newfs -O2 ${ROOT}
mkdir ${mnt}
mount /dev/${ROOT} ${mnt}

echo "Installing sets"
for w in base etc kern-GENERIC man modules; do
    echo Installing set: $w
    cd ${mnt} && pax -zrpe -f ${SETSDIR}/$w.tgz
done

cd ${mnt}

echo "Make it bootable"
# Make it bootable:
cp usr/mdec/boot .
installboot -vf -o timeout=2 -o console=${SERIAL} -o speed=${SERIALSPEED} /dev/r${ROOT} /usr/mdec/bootxx_ffsv2
# ...only make sure that this boot code corresponds to file system in newfs above.

echo "Populate /dev"
# Populate /dev
(cd dev && sh MAKEDEV all)

echo "Create additional mount points (kern, proc)"
# Additional mount points:
mkdir proc kern

echo "Generate fstab"
# Generate fstab
cat > etc/fstab <<EOF
NAME=${ROOT_LABEL} / ffs rw,log 1 1
NAME=${SWAP_LABEL} none swap sw 0 0
ptyfs /dev/pts ptyfs rw
kernfs /kern kernfs rw
procfs /proc procfs rw
tmpfs /tmp tmpfs rw
EOF

echo "Generate rc.conf"
# Generate rc.conf
cat > etc/rc.conf <<EOF
if [ -r /etc/defaults/rc.conf ]; then
    . /etc/defaults/rc.conf
fi
rc_configured=yes
hostname=${HOSTNAME}
sshd=YES
sshd_flags="-u0"
dhcpcd=YES
ifconfig_${IFDEV}="dhcp"
EOF

echo "Setting root password"
sed -i "s!^root::!root:${PASSWD}:!" ${mnt}/etc/master.passwd

# pkgsrc
if [ ! "x${PKGSRC}" = "x" ]; then
    echo "Installing pkgsrc..."
    ftp -o- ftp://ftp.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.gz | tar -zxpf- -C ${mnt}/usr
fi

# Set up vagrant user account, pw: vagrant
chroot ${mnt} useradd -p '$sha1$22526$CHHJ53UQ$oSPxmOJn0jKxlMWFea8p6KlTpHj/' -s /bin/sh -G wheel -b /home -m -c "Vagrant User" vagrant;
chown 1000:100 ${mnt}/home/vagrant;

echo "Finalization"
# Wrap up:
sync
cd / # don't hold file system
umount ${mnt}
rmdir ${mnt}

echo "Done!"
