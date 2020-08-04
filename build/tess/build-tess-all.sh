#!/bin/bash
set -e

cd `dirname ${0}`
#
# compile ios library
./build-tess-ios.sh armv7
./build-tess-ios.sh arm64
./build-tess-ios.sh i386
./build-tess-ios.sh x86_64

#
# build universal library
install_dir=$HOME/deps/ios
universal_dir=$HOME/deps/ios/universal
mkdir -p $universal_dir/lib
cp -rf $install_dir/armv7/include $universal_dir/
for f in $install_dir/armv7/lib/*.a
do
    name=$(basename $f)
    lipo -create $install_dir/armv7/lib/$name $install_dir/arm64/lib/$name $install_dir/i386/lib/$name $install_dir/x86_64/lib/$name -output $universal_dir/lib/$name
done

#
# compile osx library
./build-tess-osx.sh

#
# compile android library 
./build-tess-android.sh arm
./build-tess-android.sh arm64
./build-tess-android.sh x86
./build-tess-android.sh x86_64