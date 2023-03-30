#!/bin/bash

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}

ostype=`uname`
script_dir=`dirname ${0}`
source_dir=$DEPS_SRC/
install_dir=$DEPS_BIN/android/
sdk_dir=$ANDROID_SDK
ndk_dir=$ANDROID_NDK

mkdir -p $install_dir
script_dir=$(absdir $script_dir)
install_dir=$(absdir $install_dir)
echo "running by source dir:"$source_dir
echo "running by install dir:"$install_dir
echo "running by source dir:"$source_dir

target_abi=""
case $1 in
    arm)
    target_abi=armeabi-v7a
    ;;
    arm64)
    target_abi=arm64-v8a
    ;;
    x86)
    target_abi=x86
    ;;
    x86_64)
    target_abi=x86_64
    ;;
esac

export PREFIX=$install_dir
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
export PKG_CONFIG_PREFIX=$PREFIX
export PKG_CONFIG_SYSROOT_DIR=/
runc=16
# llvm-config --libs --cflags libjpeg

# build qt5
cd $source_dir/qt-everywhere-src
# rm -rf build_$1
mkdir -p build_$1
cd build_$1
../configure -nomake examples -skip qtdeclarative -static -opensource -confirm-license -xplatform android-clang -prefix $install_dir -android-ndk $ndk_dir -android-sdk $sdk_dir -android-arch $target_abi
# make clean
make -j $runc
make install
cd ../