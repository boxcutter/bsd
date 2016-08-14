#!/bin/sh -u

if [ "$PACKER_BUILDER_TYPE" = "virtualbox-iso" ]; then
    echo "==> No VirtualBox guest additions except for FreeBSD, continuing"
fi
