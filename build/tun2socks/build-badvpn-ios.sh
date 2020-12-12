#!/bin/bash

export LANGUAGE="en_US.UTF-8"
export LANG=en_US.UTF-8
export LC_ALL=C

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}

script_dir=`dirname ${0}`
install_dir=$HOME/deps/ios/$1/
source_dir=$HOME/deps_src/

if [ ! -z "$PREFIX" ];then
    install_dir=$PREFIX
fi
if [ ! -z "$SOURCE" ];then
    source_dir=$SOURCE
fi

mkdir -p $install_dir
script_dir=$(absdir $script_dir)
install_dir=$(absdir $install_dir)
source_dir=$(absdir $source_dir)

export PREFIX=$install_dir
export SDKVERSION=9.0
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
runc=16
platform=""
case $1 in
    armv7)
    platform=OS
    ;;
    arm64)
    platform=OS64
    ;;
    i386)
    platform=SIMULATOR
    ;;
    x86_64)
    platform=SIMULATOR64
    ;;
esac

echo "running by source dir:"$source_dir
echo "running by install dir:"$install_dir
echo "running by source dir:"$source_dir
echo "running by sdk:"$SDKVERSION
echo "running by platform:"$platform
echo "running by runc:"$runc

# build badvpn
cd $source_dir/badvpn/tun2socks/
rm -rf ios
mkdir -p ios
cd ios
cmake .. -G Xcode  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -DBUILD_SHARED_LIBS=off
# make clean
# make -j $runc
# make install
cd ../../
