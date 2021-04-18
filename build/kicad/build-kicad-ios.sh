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

cd $source_dir/libjpeg/
autoreconf -fi
$script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make clean
make -j $runc
make install
cd ../

cd $source_dir/libpng/
autoreconf -fi
$script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make clean
make -j $runc
make install
cd ../

cd $source_dir/tiff/
autoreconf -fi
$script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make clean
make -j $runc
make install
cd ../

cd $source_dir/libwebp
./autogen.sh
$script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make clean
make -j $runc
make install
cd ../

cd $source_dir/openjpeg
rm -rf build
mkdir -p build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DARCHS=$1 -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_BITCODE=ON
# make clean
make -j $runc
make install
cd ../../

# build glm
cd $source_dir/glm
cp -rf glm $install_dir/include/

# build pixman
cd $source_dir/pixman
./autogen.sh
$script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make clean
make -j $runc
make install
cd ../

# build cairo
cd $source_dir/cairo
./autogen.sh
$script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
# make clean
CPPFLAGS=-DDEBUG CFLAGS="-g -O0" make -j $runc
make install
cd ../

# build freetype(no harfbuzz)
cd $source_dir/freetype
rm -rf build
mkdir -p build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -Wno-dev
# make clean
make -j $runc
make install
cd ../../

# build harfbuzz
cd $source_dir/harfbuzz
rm -rf build
mkdir -p build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -Wno-dev -DHB_HAVE_FREETYPE=ON
# make clean
make -j $runc
make install
cd ../../

# build freetype
cd $source_dir/freetype
rm -rf build
mkdir -p build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -Wno-dev
# make clean
make -j $runc
make install
cd ../../

# build oce
cd $source_dir/oce
rm -rf build
mkdir -p build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
# make clean
make -j $runc
make install
cd ../../

# build glu
cd $source_dir/glu
rm -rf build
mkdir -p build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
# make clean
make -j $runc
make install
cd ../../

# build wxwidgets
cd /Users/cny/git/wxWidgets
rm -rf build_ios_$1
mkdir -p build_ios_$1
cd build_ios_$1
$script_dir/../ios-autotools/iconfigure $1 --with-iphone --with-expat=builtin --enable-monolithic --enable-aui --enable-glcanvasegl=yes --enable-debug
# # make clean
make -j $runc
make install
cd ../

# build kicad
cd /Users/cny/git/kicad/kicad/
if [ "$2" == "" ];then
    # rm -rf build/ios_$1
    mkdir -p build/ios_$1
    cd build/ios_$1
else
    # rm -rf build/ios_$1_xc
    mkdir -p build/ios_$1_xc
    cd build/ios_$1_xc
fi

cmake ../../ $2 -Wno-dev -DCMAKE_BUILD_TYPE=Debug \
    -DKICAD_SCRIPTING=OFF -DKICAD_USE_EGL=ON -DKICAD_USER_PLUGIN=OFF -DBUILD_GITHUB_PLUGIN=OFF \
    -DKICAD_USE_OCE=OFF -DKICAD_USE_OCC=ON -DOCC_INCLUDE_DIR=$install_dir/include/opencascade/ \
    -DwxWidgets_INCLUDE_DIRS=$install_dir/include/wx-3.1/ -DwxWidgets_LIBRARIES=$install_dir/lib/ \
    -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform \
    -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir \
    -DLEMON_EXE=$install_dir/bin/lemon \
    -DKICAD_BUILD_QA_TESTS=OFF -DUSE_KIWAY_DLLS=OFF -DKICAD_SPICE=OFF \
    -DARCHS=$1 -DENABLE_BITCODE=ON -DCMAKE_CXX_FLAGS=-fno-objc-arc

if [ "$2" == "" ];then
    # make -j$runc 3d-viewer connectivity pnsrouter pcad2kicadpcb lib_dxf idf3 legacy_wx legacy_gal viewer_kiface eeschema_kiface pcbnew_kiface_objects s3d_plugin_idf s3d_plugin_vrml s3d_plugin_oce 
    make -j$runc viewer
    mkdir -p ../../out/$1/include ../../out/$1/lib
    find . -name '*.a' -exec cp {} ../../out/$1/lib \;
    cp -f config.h ../../out/$1/include
fi