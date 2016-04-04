#!/bin/sh -u
echo "export PKG_PATH=$OPENBSD_MIRROR/`uname -r`/packages/`machine -a`" >> $HOME/.profile
