#!/bin/sh -u

major_version="`uname -r | awk -F. '{print $1}'`";
minor_version="`uname -r | awk -F. '{print $2}'`";

echo "==> Setup NTP";
# Set the time correctly
echo 'ntpd_flags=""' >> /etc/rc.conf.local

echo "==> Install curl, ca_root_nss and sudo";
# Install sudo, curl and ca_root_nss
pkg_add -I curl;
pkg_add -I ca_root_nss;

# Use "doas" from 5.8
if [ "$major_version" -le 5 && "$minor_version" -lt 8 ]; then
  pkg_add -I sudo;
else
  echo 'alias sudo="echo \"Use doas instead of sudo!\""' > /home/${SSH_USERNAME}/.profile
fi

echo "==> Enable NFS";
# As sharedfolders are not in defaults ports tree, we will use NFS sharing
cat >>/etc/rc.conf.local << RC_CONF
rpcbind_enable="YES"
nfs_server_enable="YES"
mountd_flags="-r"
RC_CONF
