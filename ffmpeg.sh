#!/bin/bash

set -e

clean(){
	rm -rf libass 
	rm -rf libdc1394 
	rm -rf celt 
	rm -rf v4l-utils 
	rm -rf openal-soft 
	rm -rf xvidcore 
	rm -rf pulseaudio 
	rm -rf lame 
	rm -rf yasm 
	rm -rf rtmpdump 
	rm -rf x264 
	rm -rf freealut
	rm -rf ffmpeg
}

do_unzip(){
	tar zxvf yasm-1.3.0.tar.gz && mv yasm-1.3.0 yasm
	unzip libass-0.13.1.zip && mv libass-0.13.1 libass
	tar zxvf libdc1394-2.2.0.tar.gz && mv libdc1394-2.2.0 libdc1394
	tar zxvf celt-0.11.1.tar.gz && mv celt-0.11.1 celt
	tar jxvf v4l-utils-1.10.0.tar.bz2 && mv v4l-utils-1.10.0 v4l-utils
	tar jxvf openal-soft-1.15.1.tar.bz2 && mv openal-soft-1.15.1 openal-soft
	unzip freealut_1_1_0.zip && mv freealut-freealut_1_1_0 freealut
	tar jxvf xvidcore-1.3.4.tar.bz2
	tar xvf pulseaudio-8.0.tar.xz && mv pulseaudio-8.0 pulseaudio
	tar zxvf lame-3.99.5.tar.gz && mv lame-3.99.5 lame
	tar xvf rtmpdump-2.3.tgz && mv rtmpdump-2.3 rtmpdump
	tar jxvf last_stable_x264.tar.bz2 && mv x264-snapshot-20160213-2245-stable x264	
	tar zxvf FFmpeg-n2.8.6.tar.gz && mv FFmpeg-n2.8.6 ffmpeg
}

if [ "$1" == "clean" ];then
	clean
	exit
fi

yum install zip unzip bzip2 gcc \
automake libtool libtool-ltdl-devel \
cmake \
gcc-c++ \
freetype-devel \
fontconfig-devel \
gnutls-devel \
fribidi-devel \
fontconfig-devel \
gsm-devel \
openjpeg-devel \
intltool \
json-c-devel \
libcap-devel \
libsndfile-devel \
openssl-devel \
speex-devel \
gtk-doc \
liboil-devel \
libtheora-devel \
bzip2 \
libvorbis-devel \
libcdio-paranoia-devel \
libX11-devel \
libjpeg-turbo-devel  -y

clean
do_unzip

export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/local/lib/pkgconfig
###
echo "#########################################"
echo "Building yasm..."
cd yasm
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building libass..."
cd libass
./autogen.sh
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building libdc1394..."
cd libdc1394
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building celt..."
cd celt
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building v4l-utils..."
cd v4l-utils
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building openal-soft..."
cd openal-soft
cmake .
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building freealut..."
cd freealut
cmake .
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building xvidcore..."
cd xvidcore/build/generic
./configure --prefix=/usr
make -j9 && make install
cd ../../../

###
echo "#########################################"
echo "Building pulseaudio..."
cd pulseaudio
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building lame..."
cd lame
./configure --prefix=/usr
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building rtmpdump..."
cd rtmpdump
make && make install
cd ../

###
echo "#########################################"
echo "Building x264..."
cd x264
./configure --prefix=/usr --enable-shared --enable-static
make -j9 && make install
cd ../

###
echo "#########################################"
echo "Building ffmpeg..."
cd ffmpeg
./configure --prefix=/usr --bindir=/usr/bin --datadir=/usr/share/ffmpeg --incdir=/usr/include/ffmpeg --libdir=/usr/lib64 --mandir=/usr/share/man --arch=x86_64 --extra-cflags='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --enable-bzlib --disable-crystalhd --enable-gnutls --enable-libass --enable-libcdio --enable-libdc1394 --disable-indev=jack --enable-libfreetype --enable-libgsm --enable-libmp3lame --enable-openal --enable-libopenjpeg --enable-libpulse --enable-librtmp --enable-libspeex --enable-libtheora --enable-libvorbis --enable-libv4l2 --enable-libx264 --enable-libxvid --enable-x11grab --enable-avfilter --enable-postproc --enable-pthreads --disable-static --enable-shared --enable-gpl --disable-debug --disable-stripping --shlibdir=/usr/lib64 --enable-runtime-cpudetect  --enable-gpl --enable-version3
make -j9 && make install
cd ../

