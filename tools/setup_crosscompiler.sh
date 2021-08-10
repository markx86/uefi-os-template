#!/bin/bash

FTP_URL="https://ftp.gnu.org/gnu"

GCC_VERSION="11.1.0"
BINUTILS_VERSION="2.36.1"

WORKDIR="/tmp/osworkdir"
BUILD_DIR="build"

TARGET="x86_64-elf"
PREFIX=$(realpath "./$TARGET-cross")



echo "Updating path..."
export PATH="$PREFIX/bin:$PATH"

echo "Creating working directory..."
mkdir -p "$WORKDIR" && cd "$WORKDIR"

echo "Creating install directory..."
mkdir -p "$PREFIX"



# Binutils
echo "Downloading binutils-$BINUTILS_VERSION..."
curl -O "$FTP_URL/binutils/binutils-$BINUTILS_VERSION.tar.gz"
echo "Uncompressing binutils-$BINUTILS_VERSION..."
tar -xf "binutils-$BINUTILS_VERSION.tar.gz"
echo "Building binutils-$BINUTILS_VERSION..."
mkdir -p "$BUILD_DIR-binutils" && cd "$BUILD_DIR-binutils"
sh -c "../binutils-$BINUTILS_VERSION/configure --target=$TARGET --enable-interwork --enable-multilib --with-sysroot --disable-nls --disable-werror --prefix=\"$PREFIX\""
make -j$(nproc)
make install
cd ..

# GCC
echo "Downloading gcc-$GCC_VERSION..."
curl -O "$FTP_URL/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"
echo "Uncompressing gcc-$GCC_VERSION..."
tar -xf "gcc-$GCC_VERSION.tar.gz"
echo "Building gcc-$GCC_VERSION..."
mkdir -p "$BUILD_DIR-gcc" && cd "$BUILD_DIR-gcc"
sh -c "../gcc-$GCC_VERSION/configure --target=$TARGET --prefix=\"$PREFIX\" --disable-nls --disable-libssp --enable-languages=c,c++ --without-headers"
make all-gcc -j$(nproc)
make all-target-libgcc -j$(nproc)
make install-gcc
make install-target-libgcc

echo
echo "Script finished executing. Be sure to check the output for errors."