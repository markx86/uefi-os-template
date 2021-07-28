#!/bin/bash

DEPS="build-essential binutils mtools qemu gdb rpm2cpio bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo gcc-multilib nasm"

if apt-cache show qemu-system-x86_64 > /dev/null; then
    DEPS="$DEPS qemu-system-x86_64"
elif apt-cache show qemu-system-x86 > /dev/null; then
    DEPS="$DEPS qemu-system-x86"
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if ! test $1 = "-y";
then
    echo "This script will install the following packages:"
    echo "$DEPS"
    read -p "Do you want to proceed? [Y/N] > " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
fi

echo "Updating repositories..."
apt-get update > /dev/null
apt-get install $1 $DEPS