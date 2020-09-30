#!/bin/bash

set -e

absdir() {
  echo "$(cd "$1" && pwd)"
}

script_dir=$(dirname ${0})
install_dir=$HOME/deps/osx
source_dir=$HOME/deps_src/

if [ ! -z "$PREFIX" ]; then
  install_dir=$PREFIX
fi
if [ ! -z "$SOURCE" ]; then
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

cd $source_dir/libjpeg/
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no
make clean
make -j $runc
make install
cd ../

cd $source_dir/libpng/
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no
make clean
make -j $runc
make install
cd ../

cd $source_dir/tiff/
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no
make clean
make -j $runc
make install
cd ../

cd $source_dir/libwebp
./autogen.sh
./configure --prefix=$install_dir --enable-shared=no
make clean
make -j $runc
make install
cd ../

cd $source_dir/openjpeg
rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX:PATH=$install_dir -DBUILD_SHARED_LIBS:BOOL=OFF
make clean
make -j $runc
make install
cd ../../

cd $source_dir/leptonica
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no
make clean
make -j $runc
make install
cd ../

cd $source_dir/tesseract
autoreconf -fi
./configure --prefix=$install_dir --enable-shared=no
make clean
make -j $runc
make install
cd ../
