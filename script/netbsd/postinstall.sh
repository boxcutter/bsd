#!/bin/sh -u

. /etc/shrc
export PATH=/sbin:/usr/sbin:/bin:/usr/bin

echo "==> Set root password";
sed -i -e 's/^root::0/root:$sha1$22526$CHHJ53UQ$oSPxmOJn0jKxlMWFea8p6KlTpHj\/:0/' /etc/master.passwd

echo "==> Setup NTP";
# Set the time correctly
echo 'ntpdate=YES' >> /etc/rc.conf

echo "==> Install curl and sudo";
# Install sudo and curl
pkg_add curl;
pkg_add sudo;

echo "==> Setup sudo";
mkdir -p /usr/pkg/etc
cat >>/usr/pkg/etc/sudoers << SUDOERS
##
## User privilege specification
##
root ALL=(ALL) ALL

## Allow members of group wheel to execute any command without a password
%wheel ALL=(ALL) NOPASSWD: ALL
SUDOERS

echo "==> Configure OpenSSHD";
sed -i -e 's/.*NoneEnabled.*/NoneEnabled yes/g' /etc/ssh/sshd_config

echo "==> Enable NFS";
# As sharedfolders are not in defaults ports tree, we will use NFS sharing
cat >>/etc/rc.conf << RC_CONF
rpcbind=YES
nfs_server=YES
mountd_flags="-r"
RC_CONF

echo "==> Don't build for X11";
# Disable X11 because Vagrants VMs are (usually) headless
cat >>/etc/mk.conf << MK_CONF
MKX11=yes
MK_CONF
