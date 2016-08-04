#!/bin/sh -u

echo "==> Update packages";
pkg update;

echo "==> Upgrade pkg";
pkg upgrade -y pkg;
