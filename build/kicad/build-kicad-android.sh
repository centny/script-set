#!/bin/bash

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}
base_dir=/Volumes/DataD/
if [ ! -z "$BASE" ];then
    ndk_dir=$BASE
fi
script_dir=`dirname ${0}`
install_dir=$base_dir/deps/android/$1/
source_dir=$base_dir/deps_src/
sdk_dir=$base_dir/android/`uname`
ndk_dir=$sdk_dir/ndk-bundle

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
export API=26

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
    export CPU_FAMILY=arm
    export CPU_NAME=armv7a
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
    export CPU_FAMILY=aarch64
    export CPU_NAME=armv8a
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
    export CPU_FAMILY=x86
    export CPU_NAME=i686
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
    export CPU_FAMILY=x86_64
    export CPU_NAME=x86_64
    ;;
esac
# Configure and build.

export PREFIX=$install_dir
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
runc=16

meson_setup() {
    cat >> "cross-file" <<EOF
[host_machine]
system = 'android'
endian = 'little'
cpu_family = '$CPU_FAMILY'
cpu = '$CPU_NAME'
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
strip = '$STRIP'
cmake = '$CMAKE'
[properties]
EOF
    meson setup \
        --prefix="$PREFIX" \
        --backend=ninja \
        --cross-file=`pwd`/cross-file \
        $@
}

set -x

# # build glew
# cd $source_dir/glew
# export source_dir
# $script_dir/../ios-autotools/iexec $1 "$script_dir/build-glew-ios.sh"

# # build glm
# cd $source_dir/glm
# cp -rf glm $install_dir/include/

# # build freeglut
# cd $source_dir/liquidfun/freeglut
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -DHAVE_XPARSEGEOMETRY=OFF -DFREEGLUT_BUILD_SHARED_LIBS=OFF -DFREEGLUT_BUILD_DEMOS=NO -DENABLE_BITCODE=ON
# make clean
# make -j $runc
# make install
# cd ../../

# # build pixman
# cd $source_dir/pixman
# rm -rf build_$1
# mkdir build_$1
# cd build_$1
# # autoreconf -v --install
# # CFLAGS="-I$ndk_dir/sources/android/cpufeatures -std=c99 -g" ./configure --prefix=$install_dir --host $TARGET --enable-shared=no
# meson_setup -Dneon=disabled -Darm-simd=disabled -Dtests=disabled -Ddefault_library=static ..
# ninja install
# cd ../

# # build cairo
# cd $source_dir/cairo
# autoreconf -v --install
# ./configure --host $TARGET --enable-shared=no
# # make clean
# CPPFLAGS=-DDEBUG CFLAGS="-g -O0" make -j $runc
# make install
# cd ../

# # build freetype(no harfbuzz)
# cd $source_dir/freetype
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -DENABLE_BITCODE=ON -Wno-dev
# make clean
# make -j $runc
# make install
# cd ../../

# # build harfbuzz
# cd $source_dir/harfbuzz
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -DENABLE_BITCODE=ON -Wno-dev -DHB_HAVE_FREETYPE=ON
# make clean
# make -j $runc
# make install
# cd ../../

# # build freetype
# cd $source_dir/freetype
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -DENABLE_BITCODE=ON -Wno-dev
# make clean
# make -j $runc
# make install
# cd ../../

# # build oce
# cd $source_dir/oce
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -DENABLE_BITCODE=ON -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
# # make clean
# make -j $runc
# make install
# cd ../../

# # build ngspice
# cd $source_dir/ngspice
# ./autogen.sh
# export ac_cv_func_malloc_0_nonnull=yes
# export ac_cv_func_realloc_0_nonnull=yes
# rm -rf build_ios
# mkdir -p build_ios
# cd build_ios
# CFLAGS=-Wno-implicit-function-declaration $script_dir/../ios-autotools/iconfigure $1 --with-ngshared --enable-xspice --enable-cider --disable-debug
# # make clean
# make -j $runc
# make install
# cd ../

# CFLAGS=-Wno-implicit-function-declaration $script_dir/../ios-autotools/iexec $1 zsh

# # build glu
# cd $source_dir/glu
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
# # make clean
# make -j $runc
# make install
# cd ../../

# # build expat
# cd $source_dir/libexpat/expat/
# ./buildconf.sh
# $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make -j $runc
# make install
# cd ../


# # build wxwidgets
# cd /Users/cny/git/wxWidgets
# # rm -rf build_android_$1
# mkdir -p build_android_$1
# cd build_android_$1
# LDFLAGS="-L$install_dir/lib/ -lGLESv2 -lQt5Gui_armeabi-v7a -lqtharfbuzz_armeabi-v7a -lqtlibpng_armeabi-v7a -lQt5Core_armeabi-v7a -lqtpcre2_armeabi-v7a -llog" ../configure --prefix=$install_dir --host $TARGET --with-qt --with-expat=builtin --enable-monolithic --enable-aui --enable-glcanvasegl=yes --enable-debug --enable-shared=no
# # make clean
# make -j $runc
# make install
# cd ../

# build kicad
cd /Users/cny/git/kicad/kicad/
if [ "$2" == "" ];then
    rm -rf build/android_$1
    mkdir -p build/android_$1
    cd build/android_$1
else
    # rm -rf build/android_$1_xc
    mkdir -p build/android_$1_xc
    cd build/android_$1_xc
fi

cmake ../../ $2 -Wno-dev -DCMAKE_BUILD_TYPE=Debug \
    -DKICAD_SCRIPTING=OFF -DKICAD_USE_EGL=ON -DKICAD_USER_PLUGIN=OFF -DBUILD_GITHUB_PLUGIN=OFF \
    -DKICAD_USE_OCE=OFF -DKICAD_USE_OCC=ON -DOCC_INCLUDE_DIR=$install_dir/include/opencascade/ \
    -DwxWidgets_INCLUDE_DIRS=$install_dir/include/wx-3.1/ -DwxWidgets_LIBRARIES=$install_dir/lib/ \
    -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir \
    -DLEMON_EXE=$install_dir/bin/lemon \
    -DKICAD_BUILD_QA_TESTS=OFF -DUSE_KIWAY_DLLS=OFF -DKICAD_SPICE=OFF \
    -DGLM_ROOT_DIR=$install_dir/include/
    -DANDROID_ABI=$CMAKE_ABI\
    -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake\
    -DANDROID_NATIVE_API_LEVEL=$API


if [ "$2" == "" ];then
    # make -j$runc 3d-viewer connectivity pnsrouter pcad2kicadpcb lib_dxf idf3 legacy_wx legacy_gal viewer_kiface eeschema_kiface pcbnew_kiface_objects s3d_plugin_idf s3d_plugin_vrml s3d_plugin_oce 
    make -j$runc viewer
    mkdir -p ../../out/android_$1/include ../../out/android_$1/lib
    find . -name '*.a' -exec cp {} ../../out/android_$1/lib \;
    cp -f config.h ../../out/android_$1/include
fi
