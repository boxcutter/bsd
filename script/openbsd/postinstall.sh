#!/bin/sh -u

major_version="$(uname -r | awk -F. '{print $1}')";
minor_version="$(uname -r | awk -F. '{print $2}')";

echo "==> Set hostname";
echo "$HOSTNAME.localdomain" > /etc/myname;

echo "==> Setup NTP";
# Set the time correctly
echo 'ntpd_flags=""' >> /etc/rc.conf.local;

echo "==> Install curl";
. /home/${SSH_USERNAME}/.profile;
pkg_add -I curl;

# Use "doas" from 5.8
if [ "$major_version" -le 5 -a "$minor_version" -lt 8 ]; then
  echo "==> Install sudo";
  pkg_add -I sudo;
else
  echo 'alias sudo="echo \"Use doas instead of sudo!\""' >> /home/${SSH_USERNAME}/.profile;
fi

echo "==> Enable NFS";
# As sharedfolders are not in defaults ports tree, we will use NFS sharing
cat >>/etc/rc.conf.local << RC_CONF
rpcbind_enable="YES"
nfs_server_enable="YES"
mountd_flags="-r"
RC_CONF
