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

runc=16
platform=""
case $1 in
    arm64)
    platform=iphoneos
    ;;
    x86_64)
    platform=iphonesimulator
    ;;
esac

echo "running by source dir:"$source_dir
echo "running by install dir:"$install_dir
echo "running by platform:"$platform
echo "running by runc:"$runc

if [ -f "$install_dir/.boost" ];then
  echo "boost is complied, skipp it"
  exit 0
fi

MIN_IOS_VERSION=11.0
IOS_SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)
IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
IOSSIM_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
EXTRA_FLAGS="-fembed-bitcode -Wno-unused-local-typedef -Wno-nullability-completeness"
EXTRA_ARM_FLAGS="-DBOOST_AC_USE_PTHREADS -DBOOST_SP_USE_PTHREADS -g -DNDEBUG"
EXTRA_IOS_FLAGS="$EXTRA_FLAGS $EXTRA_ARM_FLAGS -mios-version-min=$MIN_IOS_VERSION"
EXTRA_IOS_SIM_FLAGS="$EXTRA_FLAGS $EXTRA_ARM_FLAGS -mios-simulator-version-min=$MIN_IOS_VERSION"
IOS_ARCH_FLAGS="-arch arm64"
IOS_SIM_ARCH_FLAGS="-arch x86_64"
OTHER_FLAGS="-std=c++14 -stdlib=libc++ -DNDEBUG"

cd $source_dir/boost_1_73_0

cat > "tools/build/src/user-config.jam" <<EOF
using darwin : iphoneos
: $COMPILER
: <architecture>arm64
  <target-os>iphone
  <cxxflags>"$CXX_FLAGS"
  <linkflags>"$LD_FLAGS"
  <compileflags>"$OTHER_FLAGS $IOS_ARCH_FLAGS $EXTRA_IOS_FLAGS -isysroot $IOS_SDK_PATH"
  <threading>multi

;
using darwin : iphonesimulator
: $COMPILER
: <architecture>x86_64
  <target-os>iphone
  <cxxflags>"$CXX_FLAGS"
  <linkflags>"$LD_FLAGS"
  <compileflags>"$OTHER_FLAGS $IOS_SIM_ARCH_FLAGS $EXTRA_IOS_SIM_FLAGS -isysroot $IOSSIM_SDK_PATH"
  <threading>multi
;
EOF

./bootstrap.sh --with-libraries=atomic,chrono,date_time,exception,filesystem,program_options,random,system,thread,test
./b2 "-j$runc" \
    --build-dir=iphone-build \
    --stagedir=iphone-build/stage \
    --prefix="$install_dir" \
    toolset="darwin-$platform" \
    link=static \
    variant=release \
    install

echo 1 > $install_dir/.boost