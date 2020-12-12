#!/bin/bash
script_dir=`dirname ${0}`
export CFLAGS_EXTRA="$CFLAGS"
export GLEW_PREFIX=$PREFIX
set -xe
git apply $script_dir/glew-build-ios.patch
cd auto
make extensions
make clean
make
cd ../
make clean
make lib install