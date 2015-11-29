#!/bin/sh -u

cat >> /etc/shrc << SHRC
export PKG_PATH=$NETBSD_MIRROR/`uname -m`/`uname -r`/All
SHRC

cat >> /etc/csh.cshrc << CSHRC
setenv PKG_PATH $NETBSD_MIRROR/`uname -m`/`uname -r`/All
CSHRC
