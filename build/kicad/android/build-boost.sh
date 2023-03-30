#!/bin/bash

set -xe

absdir() {
  echo "$(cd "$1" && pwd)"
}

host_os_tag() {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     echo "linux-x86_64";;
        Darwin*)    echo "darwin-x86_64";;
        *)          echo "host_os_tag_unknown"
    esac
    
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

cd Boost-for-Android
./build-android.sh $ndk_dir
cp -rf build/out/armeabi-v7a/ $install_dir/arm/
cp -rf build/out/arm64-v8a/ $install_dir/arm64/
cp -rf build/out/x86/ $install_dir/x86/
cp -rf build/out/x86_64/ $install_dir/x86_64/
cd ..
