#!/bin/bash
docker rm -f android-kicad
docker run -d --privileged --name android-kicad \
    -v $HOME/deps:$HOME/deps -e DEPS_BIN=$HOME/deps \
    -v $HOME/deps_src:$HOME/deps_src -e DEPS_SRC=$HOME/deps_src \
    -v $HOME/pkg/android:/android -e ANDROID_SDK=/android/sdk -e ANDROID_NDK=/android/ndk \
    -v $(pwd):/build/ -w /build \
    -e HTTPS_PROXY=http://192.168.1.9:1105 \
    registry.sxbastudio.com/ubuntu-vm:22.04 init