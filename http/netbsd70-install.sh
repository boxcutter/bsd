#!/bin/sh -x

# This follows http://www.nibel.net/nbsdeng/ap-inst.html
# Created by Rickard von Essen (rickard.von.essen@gmail.com)

NAME=$1
DISKSLICE=$2
IFDEV=wm0

fdisk -f -a -u -0 -s 169/63/134217665 $DISKSLICE;

cat << DISKLABEL > /tmp/protofile
# /dev/r${DISKSLICE}d:
type: ESDI
disk: harddisk1 SSD
label: fictitious
flags:
bytes/sector: 512
sectors/track: 63
tracks/cylinder: 16
sectors/cylinder: 1008
cylinders: 133152
total sectors: 134217728
rpm: 3600
interleave: 1
trackskew: 0
cylinderskew: 0
headswitch: 0 # microseconds
track-to-track seek: 0 # microseconds
drivedata: 0

4 partitions:
#        size    offset    fstype [fsize bsize cpg/sgs]
 a: 129894337        63    4.2BSD      0     0     0  # (Cyl.      63 - 128863*)
 b:   4323328 129894400      swap                     # (Cyl.  128863*- 133152*)
 c: 134217665        63    unused      0     0        # (Cyl.       0*- 133152*)
 d: 134217728         0    unused      0     0        # (Cyl.       0 - 133152*)
DISKLABEL

disklabel -R -r $DISKSLICE /tmp/protofile;

newfs -m 5 -b 8192 -f 1024 -i 32768 /dev/r${DISKSLICE}a;

mount -o async,noatime /dev/${DISKSLICE}a /targetroot;

cat /amd64/binary/sets/base.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/comp.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/etc.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/kern-GENERIC.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/man.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/misc.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/text.tgz | tar --unlink -xpzf - -C /targetroot;
cat /amd64/binary/sets/modules.tgz | tar --unlink -xpzf - -C /targetroot;

cp /usr/mdec/boot /targetroot/;
installboot -v -o timeout=3 /dev/r${DISKSLICE}a /usr/mdec/bootxx_ffsv1;

chroot /targetroot sh -c 'cd /dev && ./MAKEDEV all';

mkdir /targetroot/kern;

cat > /targetroot/etc/fstab << FSTAB
/dev/${DISKSLICE}a / ffs rw,log,noatime 1 1
/dev/${DISKSLICE}b none swap sw 0 0
/kern /kern kernfs rw
FSTAB

# Set up vagrant user account, pw: vagrant
chroot /targetroot useradd -p '$sha1$22526$CHHJ53UQ$oSPxmOJn0jKxlMWFea8p6KlTpHj/' -s /bin/sh -G wheel -b /home -m -c "Vagrant User" vagrant;

chown 1000:100 /targetroot/home/vagrant;

# Enable required services
sed -i -e 's/rc_configured=NO/rc_configured=YES/' /targetroot/etc/rc.conf;
echo "sshd=YES" >> /targetroot/etc/rc.conf;
echo "hostname=$NAME" >> /targetroot/etc/rc.conf;
echo "ifconfig_${IFDEV}=\"dhcp\"" >> /targetroot/etc/rc.conf;

sync;
