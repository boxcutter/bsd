#!/bin/sh -u

echo "==> Zero out the free space to save space in the final image";
COMPRESSION=`zfs get -H compression zroot | cut -f3`;

zfs set compression=off zroot;
dd if=/dev/zero of=/EMPTY bs=1m || echo "dd exit code $? is suppressed";
rm -f /EMPTY;
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync;
zfs set compression=$COMPRESSION zroot;
