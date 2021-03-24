#!/bin/bash

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}

script_dir=`dirname ${0}`
install_dir=$HOME/deps/android/$1/
source_dir=$HOME/deps_src/
ndk_dir=$HOME/android/`uname`/ndk-bundle

if [ ! -z "$PREFIX" ];then
    install_dir=$PREFIX
fi
if [ ! -z "$SOURCE" ];then
    source_dir=$SOURCE
fi
if [ ! -z "$NDK" ];then
    ndk_dir=$NDK
fi

mkdir -p $install_dir
script_dir=$(absdir $script_dir)
install_dir=$(absdir $install_dir)
source_dir=$(absdir $source_dir)
echo "running by source dir:"$source_dir
echo "running by install dir:"$install_dir
echo "running by source dir:"$source_dir


# Only choose one of these, depending on your build machine...
ostype=`uname`
if [ "$ostype" == "Darwin" ];then
    export TOOLCHAIN=$ndk_dir/toolchains/llvm/prebuilt/darwin-x86_64
else
    export TOOLCHAIN=$ndk_dir/toolchains/llvm/prebuilt/linux-x86_64
fi

# Set this to your minSdkVersion.
export API=21

case $1 in
    arm)
    export TARGET=armv7a-linux-androideabi
    export CMAKE_ABI=armeabi-v7a
    export AR=$TOOLCHAIN/bin/arm-linux-androideabi-ar
    export AS=$TOOLCHAIN/bin/arm-linux-androideabi-as
    export CC=$TOOLCHAIN/bin/$TARGET$API-clang
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
    export LD=$TOOLCHAIN/bin/arm-linux-androideabi-ld
    export RANLIB=$TOOLCHAIN/bin/arm-linux-androideabi-ranlib
    export STRIP=$TOOLCHAIN/bin/arm-linux-androideabi-strip
    ;;
    arm64)
    export TARGET=aarch64-linux-android
    export CMAKE_ABI=arm64-v8a
    export AR=$TOOLCHAIN/bin/$TARGET-ar
    export AS=$TOOLCHAIN/bin/$TARGET-as
    export CC=$TOOLCHAIN/bin/$TARGET$API-clang
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
    export LD=$TOOLCHAIN/bin/$TARGET-ld
    export RANLIB=$TOOLCHAIN/bin/$TARGET-ranlib
    export STRIP=$TOOLCHAIN/bin/$TARGET-strip
    ;;
    x86)
    export TARGET=i686-linux-android
    export CMAKE_ABI=x86
    export AR=$TOOLCHAIN/bin/$TARGET-ar
    export AS=$TOOLCHAIN/bin/$TARGET-as
    export CC=$TOOLCHAIN/bin/$TARGET$API-clang
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
    export LD=$TOOLCHAIN/bin/$TARGET-ld
    export RANLIB=$TOOLCHAIN/bin/$TARGET-ranlib
    export STRIP=$TOOLCHAIN/bin/$TARGET-strip
    ;;
    x86_64)
    export TARGET=x86_64-linux-android
    export CMAKE_ABI=x86_64
    export AR=$TOOLCHAIN/bin/$TARGET-ar
    export AS=$TOOLCHAIN/bin/$TARGET-as
    export CC=$TOOLCHAIN/bin/$TARGET$API-clang
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
    export LD=$TOOLCHAIN/bin/$TARGET-ld
    export RANLIB=$TOOLCHAIN/bin/$TARGET-ranlib
    export STRIP=$TOOLCHAIN/bin/$TARGET-strip
    ;;
esac
# Configure and build.

export PREFIX=$install_dir
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
runc=16

cd $source_dir/libjpeg/
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no --host $TARGET
make clean
make -j $runc
make install
cd ../

cd $source_dir/libpng/
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no --host $TARGET
make clean
make -j $runc
make install
cd ../

cd $source_dir/tiff/
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no --host $TARGET
make clean
make -j $runc
make install
cd ../

cd $source_dir/libwebp
./autogen.sh
./configure --prefix=$install_dir --enable-shared=no --host $TARGET
make clean
make -j $runc
make install
cd ../

cd $source_dir/openjpeg
rm -rf build
mkdir -p build
cd build
cmake -DANDROID_ABI=$CMAKE_ABI\
    -DANDROID_NDK=$ndk_dir\
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$install_dir\
    -DCMAKE_INSTALL_PREFIX:PATH=$install_dir\
    -DCMAKE_BUILD_TYPE=Release\
    -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake\
    -DANDROID_NATIVE_API_LEVEL=$API\
    -DANDROID_TOOLCHAIN=clang\
    -DBUILD_SHARED_LIBS:BOOL=OFF\
    ..
make clean
make -j $runc
make install
cd ../../

# cd $source_dir/leptonica
# autoreconf -fi
# ./configure --prefix=$install_dir --enable-shared=no --host $TARGET
# make clean
# make -j $runc
# make install
# cd ../

# cd $source_dir/tesseract
# autoreconf -fi
# ./configure --prefix=$install_dir --enable-shared=no --host $TARGET
# make clean
# make -j $runc
# make install
# cd ../

