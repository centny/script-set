#!/bin/bash
./boost.sh -ios --no-framework --ios-archs armv7
cp -rf $HOME/deps_src/boost_1_73_0/build/boost/1.73.0/ios/release/prefix/include/boost $HOME/deps/ios/armv7/include/
cp -rf $HOME/deps_src/boost_1_73_0/build/boost/1.73.0/ios/release/prefix/lib/* $HOME/deps/ios/armv7/lib/
# ./boost.sh -ios --no-framework --universal
# cp -rf $HOME/deps_src/boost_1_73_0/build/boost/1.73.0/ios/release/prefix/include/boost $HOME/deps/ios/universal/include/
# cp -rf $HOME/deps_src/boost_1_73_0/build/boost/1.73.0/ios/release/prefix/lib/* $HOME/deps/ios/universal/lib/