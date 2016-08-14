#!/bin/sh -u

if [ "$PACKER_BUILDER_TYPE" = "vmware-iso" ]; then
    echo "==> No VMware tools support except for FreeBSD, continuing"
fi
