#!/bin/bash

set -e
set -x

mkdir ~/unbound && cd ~/unbound

PREFIX=/jffs

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-O3 -mtune=mips32 -mips32 -ffunction-sections -fdata-sections"
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir -p $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET http://zlib.net/zlib-1.2.8.tar.gz
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--static \
--prefix=$PREFIX

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

mkdir -p $SRC/openssl && cd $SRC/openssl
$WGET https://www.openssl.org/source/openssl-1.0.2f.tar.gz
tar zxvf openssl-1.0.2f.tar.gz
cd openssl-1.0.2f

./Configure linux-mips32 \
-mtune=mips32 -mips32 -ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=$PREFIX zlib \
--with-zlib-lib=$DEST/lib \
--with-zlib-include=$DEST/include

make CC=mipsel-linux-gcc
make CC=mipsel-linux-gcc install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

######### ###################################################################
# EXPAT # ###################################################################
######### ###################################################################

mkdir $SRC/expat && cd $SRC/expat
$WGET http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz
tar zxvf expat-2.1.0.tar.gz
cd expat-2.1.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--enable-static \
--disable-shared

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# UNBOUND # #################################################################
########### #################################################################

mkdir $SRC/unbound && cd $SRC/unbound
$WGET https://www.unbound.net/downloads/unbound-1.5.7.tar.gz
tar zxvf unbound-1.5.7.tar.gz
cd unbound-1.5.7

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--with-ssl=$DEST \
--with-libexpat=$DEST \
--enable-static-exe \
--enable-static \
--disable-shared \
--disable-flto

$MAKE LIBS="-all-static -lcrypto -lz -ldl"
make install DESTDIR=$BASE/unbound
