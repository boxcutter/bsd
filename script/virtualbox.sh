#!/bin/sh -u

freebsd_major="`uname -r | awk -F. '{print $1}'`";

if [ $PACKER_BUILDER_TYPE == virtualbox-iso ]; then
    echo "==> No VirtualBox guest additions for OpenBSD, continuing";
fi
