#!/bin/bash

DEPS="build-essential binutils mtools qemu qemu-system-x86_64 gdb"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "This script will install the following packages:"
echo "$DEPS"
read -p "Do you want to proceed? [Y/N] > " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo "Updating repositories..."
apt-get update > /dev/null
apt-get install $DEPS