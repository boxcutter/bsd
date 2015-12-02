#!/bin/sh -u

echo "==> Disk usage before cleanup";
df -h;

# Purge files we don't need any longer
echo "==> Removing sources";
rm -rf /usr/src/*;
echo "==> Removing core dumps";
rm -f /*.core;

echo "==> Disk usage after cleanup";
df -h;
