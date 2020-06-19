#!/bin/bash

set -e

cd `dirname ${0}`
#./build-tess-ios.sh armv7
#./build-tess-ios.sh arm64
#./build-tess-ios.sh i386
#./build-tess-ios.sh x86_64
# ./build-tess-osx.sh

./build-tess-android.sh arm
./build-tess-android.sh arm64
./build-tess-android.sh x86
./build-tess-android.sh x86_64