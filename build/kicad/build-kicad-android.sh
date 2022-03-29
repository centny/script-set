#!/bin/bash

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}

ostype=`uname`
script_dir=`dirname ${0}`
install_dir=$HOME/deps/android/$1/
source_dir=$HOME/deps_src/
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


if [ -f "$install_dir/.libjpeg" ];then
    echo "libjpeg is complied, skipp it"
else
    cd $source_dir/libjpeg/
    autoreconf -fi
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir
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
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir
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
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir
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
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir
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
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -Wno-dev
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
fi

# if [ -f "$install_dir/.freeglut" ];then
#     echo "freeglut is complied, skipp it"
# else
#     # build freeglut
#     cd $source_dir/liquidfun/freeglut
#     rm -rf build
#     mkdir -p build
#     cd build
#     cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API -DHAVE_XPARSEGEOMETRY=OFF -DFREEGLUT_BUILD_SHARED_LIBS=OFF -DFREEGLUT_BUILD_DEMOS=NO -DENABLE_BITCODE=ON
#     make clean
#     make -j $runc
#     make install
#     cd ../../
# fi

# build pixman
if [ -f "$install_dir/.pixman" ];then
    echo "pixman is complied, skipp it"
else
    cd $source_dir/pixman
    rm -rf build_$1
    mkdir build_$1
    cd build_$1
    # autoreconf -v --install
    # CFLAGS="-I$ndk_dir/sources/android/cpufeatures -std=c99 -g" ./configure --prefix=$install_dir --host $TARGET --enable-shared=no
    meson_setup -Dneon=disabled -Darm-simd=disabled -Dtests=disabled -Ddefault_library=static ..
    ninja install
    cd ../
    echo 1 > $install_dir/.pixman
fi

# build cairo
if [ -f "$install_dir/.cairo" ];then
    echo "cairo is complied, skipp it"
else
    cd $source_dir/cairo
    autoreconf -v --install
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir 
    # make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.cairo
fi

# build freetype(no harfbuzz)
if [ -f "$install_dir/.freetype" ];then
    echo "freetype is complied, skipp it"
else
    cd $source_dir/freetype
    ./autogen.sh
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir --with-harfbuzz=no
    make -j $runc
    make install
    cd ../
fi

# build harfbuzz
if [ -f "$install_dir/.harfbuzz" ];then
    echo "harfbuzz is complied, skipp it"
else
    cd $source_dir/harfbuzz
    NOCONFIGURE=1 ./autogen.sh
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir --with-freetype=yes --with-cairo=yes
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.harfbuzz
fi

# build freetype
if [ -f "$install_dir/.freetype" ];then
    echo "freetype is complied, skipp it"
else
    cd $source_dir/freetype
    ./autogen.sh
    ./configure --host $TARGET --enable-shared=no --prefix=$install_dir --with-harfbuzz=yes
    make -j $runc
    make install
    cd ../
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
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API \
        -DFREETYPE_INCLUDE_DIRS=$install_dir/include -DFREETYPE_LIBRARY=$install_dir/lib -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
    # make clean
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
    cmake ..  -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DANDROID_ABI=$CMAKE_ABI -DANDROID_NATIVE_API_LEVEL=$API \
        -DBUILD_MODULE_Draw=OFF -Wno-dev -DBUILD_LIBRARY_TYPE=Static
    make -j $runc
    make install
    cd ../../
    echo 1 > $install_dir/.glu
fi


# build wxwidgets
if [ -f "$install_dir/.wxWidgets" ];then
    echo "wxWidgets is complied, skipp it"
else
    pkg-config --exists --print-errors "Qt5Core Qt5Widgets Qt5Gui Qt5OpenGL Qt5Test"
    cd ~/test/wxWidgets
    # rm -rf build_android_$1
    mkdir -p build_android_$1
    cd build_android_$1
    # LDFLAGS="-L$install_dir/lib/ -lGLESv2 -lQt5Gui_arm64-v8a -lqtharfbuzz_arm64-v8a -lqtlibpng_arm64-v8a -lQt5Core_arm64-v8a -lqtpcre2_arm64-v8a -llog" ../configure --prefix=$install_dir --with-qt --host $TARGET --with-expat=builtin --enable-monolithic --enable-aui --enable-glcanvasegl=yes --enable-debug --enable-shared=no
    ../configure --with-qt --enable-debug \
        --host=$TARGET  --disable-compat28 --disable-shared \
        --disable-arttango --enable-image --disable-dragimage --disable-sockets \
        --with-libtiff=no --without-opengl --disable-baseevtloop --disable-utf8
    # make clean
    make -j $runc
    make install
    cd ../
    echo 1 > $install_dir/.wxWidgets
fi

# build kicad
# cd /Users/cny/git/kicad/kicad/
# if [ "$2" == "" ];then
#     rm -rf build/android_$1
#     mkdir -p build/android_$1
#     cd build/android_$1
# else
#     # rm -rf build/android_$1_xc
#     mkdir -p build/android_$1_xc
#     cd build/android_$1_xc
# fi

# cmake ../../ $2 -Wno-dev -DCMAKE_BUILD_TYPE=Debug \
#     -DKICAD_SCRIPTING=OFF -DKICAD_USE_EGL=ON -DKICAD_USER_PLUGIN=OFF -DBUILD_GITHUB_PLUGIN=OFF \
#     -DKICAD_USE_OCE=OFF -DKICAD_USE_OCC=ON -DOCC_INCLUDE_DIR=$install_dir/include/opencascade/ \
#     -DwxWidgets_INCLUDE_DIRS=$install_dir/include/wx-3.1/ -DwxWidgets_LIBRARIES=$install_dir/lib/ \
#     -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir \
#     -DLEMON_EXE=$install_dir/bin/lemon \
#     -DKICAD_BUILD_QA_TESTS=OFF -DUSE_KIWAY_DLLS=OFF -DKICAD_SPICE=OFF \
#     -DGLM_ROOT_DIR=$install_dir/include/
#     -DANDROID_ABI=$CMAKE_ABI\
#     -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake\
#     -DANDROID_NATIVE_API_LEVEL=$API


# if [ "$2" == "" ];then
#     # make -j$runc 3d-viewer connectivity pnsrouter pcad2kicadpcb lib_dxf idf3 legacy_wx legacy_gal viewer_kiface eeschema_kiface pcbnew_kiface_objects s3d_plugin_idf s3d_plugin_vrml s3d_plugin_oce 
#     make -j$runc viewer
#     mkdir -p ../../out/android_$1/include ../../out/android_$1/lib
#     find . -name '*.a' -exec cp {} ../../out/android_$1/lib \;
#     cp -f config.h ../../out/android_$1/include
# fi

# build kicad
if [ -f "$install_dir/.kicad" ];then
    echo "kicad is complied, skipp it"
else
    cd /Users/cny/git/kicad/kicad/
    if [ "$2" == "" ];then
        rm -rf build_android_$1
        mkdir -p build_android_$1
        cd build_android_$1
    else
        # rm -rf build/ios_$1_xc
        mkdir -p build/ios_$1_xc
        cd build/ios_$1_xc
    fi
    pkg-config --exists --print-errors "cairo"
    cmake ../ $2 -Wno-dev -DCMAKE_BUILD_TYPE=Debug \
        -DKICAD_SCRIPTING=OFF -DKICAD_USE_EGL=ON -DKICAD_USER_PLUGIN=OFF -DBUILD_GITHUB_PLUGIN=OFF \
        -DKICAD_USE_OCE=OFF -DKICAD_USE_OCC=ON -DOCC_INCLUDE_DIR=$install_dir/include/opencascade/ \
        -DwxWidgets_INCLUDE_DIRS=$install_dir/include/wx-3.1/ -DwxWidgets_LIBRARIES=$install_dir/lib/ \
        -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DCMAKE_PREFIX_PATH=$install_dir \
        -DKICAD_BUILD_QA_TESTS=OFF -DUSE_KIWAY_DLLS=OFF -DKICAD_SPICE=OFF \
        -DGLM_ROOT_DIR=$install_dir/include/glm/ \
        -DANDROID_ABI=$CMAKE_ABI\
        -DCMAKE_TOOLCHAIN_FILE=$ndk_dir/build/cmake/android.toolchain.cmake\
        -DANDROID_NATIVE_API_LEVEL=$API

    if [ "$2" == "" ];then
        # make -j$runc 3d-viewer connectivity pnsrouter pcad2kicadpcb lib_dxf idf3 legacy_wx legacy_gal viewer_kiface eeschema_kiface pcbnew_kiface_objects s3d_plugin_idf s3d_plugin_vrml s3d_plugin_oce 
        make -j$runc viewer
        mkdir -p ../../out/$1/include ../../out/$1/lib
        find . -name '*.a' -exec cp {} ../../out/$1/lib \;
        cp -f config.h ../../out/$1/include
        echo 1 > $install_dir/.kicad
    fi
fi