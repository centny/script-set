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

if [ -f "$install_dir/.libjpeg" ];then
    echo "libjpeg is complied, skipp it"
else
    cd $source_dir/libjpeg/
    autoreconf -fi
    $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
    make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.libjpeg
fi

if [ -f "$install_dir/.libpng" ];then
    echo "libpng is complied, skipp it"
else
    cd $source_dir/libpng/
    autoreconf -fi
    $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
    make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.libpng
fi

if [ -f "$install_dir/.tiff" ];then
    echo "tiff is complied, skipp it"
else
    cd $source_dir/tiff/
    autoreconf -fi
    $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
    make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.tiff
fi

if [ -f "$install_dir/.libwebp" ];then
    echo "libwebp is complied, skipp it"
else
    cd $source_dir/libwebp
    ./autogen.sh
    $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
    make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.libwebp
fi

if [ -f "$install_dir/.openjpeg" ];then
    echo "openjpeg is complied, skipp it"
else
    cd $source_dir/openjpeg
    rm -rf build
    mkdir -p build
    cd build
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DARCHS=$1 -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_BITCODE=ON
    make -j $runc
    make install
    cd ../../
    echo 1 > $install_dir/.openjpeg
fi

# build glm
if [ -f "$install_dir/.glm" ];then
    echo "glm is complied, skipp it"
else
    cd $source_dir/glm
    cp -rf glm $install_dir/include/
    echo 1 > $install_dir/.glm
fi

# build pixman
if [ -f "$install_dir/.pixman" ];then
    echo "pixman is complied, skipp it"
else
    cd $source_dir/pixman
    ./autogen.sh
    $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
    make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.pixman
fi

# build cairo
if [ -f "$install_dir/.cairo" ];then
    echo "cairo is complied, skipp it"
else
    cd $source_dir/cairo
    ./autogen.sh
    $script_dir/../ios-autotools/iconfigure $1 --enable-shared=no
    make clean
    CPPFLAGS=-DDEBUG CFLAGS="-g -O0" make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.cairo
fi

# build freetype(no harfbuzz)
if [ -f "$install_dir/.freetype" ];then
    echo "freetype is complied, skipp it"
else
    cd $source_dir/freetype
    rm -rf build
    mkdir -p build
    cd build
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -Wno-dev
    make -j $runc
    make install
    cd ../../
fi

# build harfbuzz
if [ -f "$install_dir/.harfbuzz" ];then
    echo "harfbuzz is complied, skipp it"
else
    cd $source_dir/harfbuzz
    rm -rf build
    mkdir -p build
    cd build
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -Wno-dev -DHB_HAVE_FREETYPE=ON
    make -j $runc
    make install
    cd ../../
    echo 1 > $install_dir/.harfbuzz
fi

# build freetype
if [ -f "$install_dir/.freetype" ];then
    echo "freetype is complied, skipp it"
else
    cd $source_dir/freetype
    rm -rf build
    mkdir -p build
    cd build
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -Wno-dev
    make -j $runc
    make install
    cd ../../
    echo 1 > $install_dir/.freetype
fi

# build oce
if [ -f "$install_dir/.oce" ];then
    echo "oce is complied, skipp it"
else
    cd $source_dir/oce
    rm -rf build
    mkdir -p build
    cd build
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
    make -j $runc
    make install
    cd ../../
    echo 1 > $install_dir/.oce
fi

# build glu
if [ -f "$install_dir/.glu" ];then
    echo "glu is complied, skipp it"
else
    cd $source_dir/glu
    rm -rf build
    mkdir -p build
    cd build
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$script_dir/../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DARCHS=$1 -DENABLE_BITCODE=ON -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
    make -j $runc
    make install
    cd ../../
    echo 1 > $install_dir/.glu
fi


# build wxwidgets
if [ -f "$install_dir/.wxWidgets" ];then
    echo "wxWidgets is complied, skipp it"
else
    cd ~/git/wxWidgets
    rm -rf build_ios_$1
    mkdir -p build_ios_$1
    cd build_ios_$1
    $script_dir/../ios-autotools/iconfigure $1 --with-iphone --with-expat=builtin --enable-monolithic --enable-aui --enable-glcanvasegl=yes --enable-debug
    make -j $runc
    make install
    cp -rf ../include/wx $install_dir/include/wx-3.1/
    cd ../
    echo 1 > $install_dir/.wxWidgets
fi

# build kicad
if [ -f "$install_dir/.kicad" ];then
    echo "kicad is complied, skipp it"
else
    cd ~/git/kicad/kicad/
    if [ "$2" == "" ];then
        rm -rf build/ios_$1
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
        echo 1 > $install_dir/.kicad
    fi
fi

echo "all is done"
