#!/bin/bash

set -e

export PKG_CONFIG_PATH=`pwd`/../deps/$1/lib/pkgconfig/
runc=8

cd libpng/
../ios-autotools/iconfigure $1 --prefix=`pwd`/../../deps/$1/
make clean
make -j $runc
make install
cd ../

cd tiff/
../ios-autotools/iconfigure $1 --prefix=`pwd`/../../deps/$1/
make clean
make -j $runc
make install
cd ../

cd libwebp
./autogen.sh
../ios-autotools/iconfigure $1 --prefix=`pwd`/../../deps/$1/
make clean
make -j $runc
make install
cd ../

cd openjpeg
mkdir -p build
cd build
platform=""
case $1 in
    arm64)
    platform=OS64
    ;;
esac
cmake ..  -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=`pwd`/../../../deps/$1/
make clean
make -j $runc
make install
cd ../../

cd leptonica
../ios-autotools/iconfigure $1 --disable-programs --prefix=`pwd`/../../deps/$1/
make clean
make -j $runc
make install
cd ../

cd tesseract
../ios-autotools/iconfigure $1 --prefix=`pwd`/../../deps/$1/
make clean
make -j $runc
make install
cd ../

