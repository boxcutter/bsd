#!/bin/sh -u

. /etc/shrc
export PATH=/sbin:/usr/sbin:/bin:/usr/bin

echo "==> Setup NTP";
# Set the time correctly
echo 'ntpdate=YES' >> /etc/rc.conf

echo "==> Install curl";
pkg_add curl;

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
