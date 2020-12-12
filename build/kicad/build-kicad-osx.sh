#!/bin/bash

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}

script_dir=`dirname ${0}`
install_dir=$HOME/deps/osx
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
echo "running by source dir:"$source_dir
echo "running by install dir:"$install_dir
echo "running by source dir:"$source_dir

export PREFIX=$install_dir
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
runc=16

# cd $source_dir/libjpeg/
# autoreconf -fi
# ./configure --prefix=$install_dir --enable-shared=no
# make clean
# make -j $runc
# make install
# cd ../

# cd $source_dir/libpng/
# autoreconf -fi
# ./configure --prefix=$install_dir --enable-shared=no
# make clean
# make -j $runc
# make install
# cd ../

# cd $source_dir/tiff/
# autoreconf -fi
# ./configure --prefix=$install_dir --enable-shared=no
# make clean
# make -j $runc
# make install
# cd ../

# cd $source_dir/libwebp
# ./autogen.sh
# ./configure --prefix=$install_dir --enable-shared=no
# make clean
# make -j $runc
# make install
# cd ../

# cd $source_dir/openjpeg
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DBUILD_SHARED_LIBS:BOOL=OFF
# make clean
# make -j $runc
# make install
# cd ../../

# # build wxwidgets
# cd $source_dir/wxwidgets
# $script_dir/../ios-autotools/iconfigure $1 --with-osx_iphone --enable-monolithic --disable-shared
# make clean
# make -j $runc
# make install
# cd ../

# # build glew
# cd $source_dir/glew
# export CFLAGS_EXTRA="$CFLAGS"
# export GLEW_PREFIX=$PREFIX
# cd auto
# make extensions
# make clean
# make
# cd ../
# make clean
# make lib install
# cd ../../

# # build glm
# cd $source_dir/glm
# cp -rf glm $install_dir/include/

# # build freeglut
# cd $source_dir/liquidfun/freeglut
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DARCHS=$1 -DHAVE_XPARSEGEOMETRY=OFF -DFREEGLUT_BUILD_SHARED_LIBS=OFF -DFREEGLUT_BUILD_DEMOS=NO -DENABLE_BITCODE=ON
# make clean
# make -j $runc
# make install
# cd ../../

# # build pixman
# cd $source_dir/pixman
# ./autogen.sh
# ./configure --enable-shared=no --prefix=$PREFIX
# make clean
# make -j $runc
# make install
# cd ../

# # build cairo
# cd $source_dir/cairo
# ./autogen.sh
# ./configure --enable-shared=no --prefix=$PREFIX
# make clean
# make -j $runc
# make install
# cd ../

# # build freetype(no harfbuzz)
# cd $source_dir/freetype
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -Wno-dev
# make clean
# make -j $runc
# make install
# cd ../../

# # build harfbuzz
# cd $source_dir/harfbuzz
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -Wno-dev -DHB_HAVE_FREETYPE=ON
# make clean
# make -j $runc
# make install
# cd ../../

# # build freetype
# cd $source_dir/freetype
# rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -Wno-dev
# make clean
# make -j $runc
# make install
# cd ../../

# # build oce
# cd $source_dir/oce
# # rm -rf build
# mkdir -p build
# cd build
# cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
# # make clean
# make -j $runc
# make install
# cd ../../

# # build wxwidgets
# cd $source_dir/wxwidgets
# rm -rf build_osx
# mkdir -p build_osx
# cd build_osx
# cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
# make clean
# make -j $runc
# make install
# cd ../../

# # build ngspice
# cd $source_dir/ngspice
# CFLAGS=-Wno-implicit-function-declaration $script_dir/../ios-autotools/iconfigure $1 --with-ngshared --disable-debug
# make clean
# make -j $runc
# make install
# cd ../

# build kicad
cd /Users/cny/git/kicad/kicad/
rm -rf build/osx
mkdir -p build/osx
cd build/osx
set -xe
cmake ../../ -Wno-dev -DCMAKE_BUILD_TYPE=Release \
    -DKICAD_SCRIPTING=OFF -DKICAD_USER_PLUGIN=OFF -DKICAD_USE_OCE=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir \
    -DwxWidgets_INCLUDE_DIRS=$install_dir/include/wx-3.1/ -DwxWidgets_LIBRARIES=$install_dir/lib/ \
    -DKICAD_BUILD_QA_TESTS=OFF -DUSE_KIWAY_DLLS=OFF
# make -j $runc