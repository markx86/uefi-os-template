#!/bin/bash

BASE_URL="https://www.kraxel.org/repos/jenkins/edk2/"
VER_TARGET="ovmf-x64"
SUB_TARGET="pure-efi"
WORKDIR="tmp"
DESTDIR=$(realpath "../ovmf-bins")

if ! command -v rpm2cpio
then
    echo "Could not find rpm2cpio. Would you like to install it?"
    read -p "Do you want to proceed? [Y/N] > " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
    sudo apt-get install rpm2cpio
fi

mkdir -p "$DESTDIR"
mkdir -p "$WORKDIR" && cd "$WORKDIR"
echo "Finding file..."
FILE_NAME=$(curl $BASE_URL | grep $VER_TARGET | grep -Po 'href="\K[^"]*')
echo $FILE_NAME
echo "Downloading latest OVMF binaries..."
curl -O "$BASE_URL/$FILE_NAME"
echo "Extracting OVMF binaries..."
mkdir -p "$VER_TARGET" && cd "$VER_TARGET"
rpm2cpio "../$FILE_NAME" | cpio -idvm
echo "Copying binaries"
BINS=$(rpm2cpio "../$FILE_NAME" | cpio -t | grep "$SUB_TARGET" | grep "edk2.git")
for BIN in $BINS
do
    cp -fv "$BIN" "$DESTDIR"
done