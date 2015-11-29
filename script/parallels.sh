#!/bin/sh -u

if [ "$PACKER_BUILDER_TYPE" = "parallels-iso" ]; then
    echo "==> No current support for Parallels tools, continuing";
fi
