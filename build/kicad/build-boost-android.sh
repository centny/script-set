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
install_dir=$HOME/deps/android/
if [ "$ostype" == "Darwin" ];then
    sdk_dir=$HOME/Library/Android/sdk
    ndk_dir=$sdk_dir/ndk-bundle
else
    sdk_dir=$HOME/Android/sdk
    ndk_dir=$sdk_dir/ndk-bundle
fi

if [ ! -z "$PREFIX" ];then
    install_dir=$PREFIX
fi
if [ ! -z "$NDK" ];then
    ndk_dir=$NDK
fi

mkdir -p $install_dir
script_dir=$(absdir $script_dir)
install_dir=$(absdir $install_dir)
echo "running by source dir:"$source_dir
echo "running by install dir:"$install_dir
echo "running by source dir:"$source_dir

cd Boost-for-Android
# ./build-android.sh $ndk_dir
cp -rf build/out/armeabi-v7a/ $install_dir/arm/
cp -rf build/out/arm64-v8a/ $install_dir/arm64/
cp -rf build/out/x86/ $install_dir/x86/
cp -rf build/out/x86_64/ $install_dir/x86_64/
cd ..
