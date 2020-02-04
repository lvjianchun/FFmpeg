#!/bin/bash -x

mkdir -p third_party
mkdir -p dist

BUILD_DIR=$PWD/build
export EM_PKG_CONFIG_PATH=$PWD/build/lib/pkgconfig
echo $PKG_CONFIG_PATH

install_package() {
	CL=$(command -v pkg-config | wc -l)
	if [ $CL -ge 1 ]
	then
		return
	fi
	apt-get update
	apt-get install -y automake
	apt-get install -y libtool
	apt-get install -y pkg-config
}

download_and_decompress() {
	URL=$1
	FILENAME=$(echo $URL | awk -F'/' '{print $NF}')
	if [ ! -f $FILENAME ]
	then
		wget $URL
	fi
	tar xzf $FILENAME
}

build_fdk_aac() {
	LAST_PWD=$(pwd)
	cd third_party
	download_and_decompress "https://downloads.sourceforge.net/opencore-amr/fdk-aac-2.0.1.tar.gz"
	cd fdk-aac-2.0.1
	sh autogen.sh
	emconfigure ./configure \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_lame() {
	LAST_PWD=$(pwd)
	cd third_party
	download_and_decompress "https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
	cd lame-3.100
	emconfigure ./configure \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_amr() {
	LAST_PWD=$(pwd)
	cd third_party
	download_and_decompress "https://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz"
	cd opencore-amr-0.1.5
	emconfigure ./configure \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_aacenc() {
	LAST_PWD=$(pwd)
	cd third_party
	download_and_decompress "https://downloads.sourceforge.net/project/opencore-amr/vo-aacenc/vo-aacenc-0.1.3.tar.gz"
	cd vo-aacenc-0.1.3
	emconfigure ./configure \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_amrwbenc() {
	LAST_PWD=$(pwd)
	cd third_party
	download_and_decompress "https://downloads.sourceforge.net/project/opencore-amr/vo-amrwbenc/vo-amrwbenc-0.1.3.tar.gz"
	cd vo-amrwbenc-0.1.3
	emconfigure ./configure \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_opus() {
	LAST_PWD=$(pwd)
	cd third_party
	download_and_decompress "https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz"
	cd opus-1.3.1
	emconfigure ./configure \
	--disable-intrinsics \
	--disable-rtcd \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_shine() {
	LAST_PWD=$(pwd)
	cd third_party/
	download_and_decompress "https://github.com/toots/shine/releases/download/3.1.1/shine-3.1.1.tar.gz"
	cd shine-3.1.1
	emconfigure ./configure \
		--disable-asm \
		--disable-thread \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

build_zlib() {
	LAST_PWD=$(pwd)
	cd third_party/
	download_and_decompress "https://www.zlib.net/zlib-1.2.11.tar.gz"
	cd zlib-1.2.11
	emconfigure ./configure \
		--prefix=$BUILD_DIR
	emmake make -j6
	emmake make install
	cd $LAST_PWD
}

configure_ffmpeg() {
	emconfigure ./configure \
	--prefix=$BUILD_DIR \
	--extra-cflags="-I$BUILD_DIR/include" \
	--extra-cxxflags="-I$BUILD_DIR/include" \
	--extra-ldflags="-L$BUILD_DIR/lib" \
	--nm="llvm-nm -g" \
	--ar=emar \
	--cc=emcc \
	--cxx=em++ \
	--objcc=emcc \
	--dep-cc=emcc \
	--disable-all \
	--disable-pthreads \
	--disable-x86asm \
	--disable-inline-asm \
	--disable-doc \
	--disable-stripping \
	--disable-ffprobe \
	--disable-ffplay \
	--disable-ffmpeg \
	--disable-asm \
	--disable-debug \
	--enable-gpl \
	--enable-nonfree \
	--enable-protocol=file \
	--target-os=none \
	--enable-version3 \
	--enable-zlib \
	--enable-decoder=wmalossless \
	--enable-decoder=wmapro \
	--enable-decoder=wmavoice \
	--enable-libfdk-aac --enable-encoder=libfdk_aac --enable-decoder=libfdk_aac\
	--enable-encoder=libshine --enable-libshine \
	--enable-encoder=libmp3lame --enable-libmp3lame \
	--enable-encoder=mp3 --enable-decoder=mp3 --enable-muxer=mp3 --enable-demuxer=mp3 \
	--enable-encoder=ac3 --enable-decoder=ac3 --enable-muxer=ac3 --enable-demuxer=ac3 --enable-parser=ac3 \
	--enable-decoder=opus --enable-encoder=libopus --enable-muxer=opus --enable-libopus --enable-parser=opus \
	--enable-encoder=pcm_s16le --enable-decoder=pcm_s16le \
	--enable-muxer=matroska --enable-demuxer=matroska \
	--enable-encoder=aac --enable-decoder=aac --enable-demuxer=aac --enable-parser=aac \
	--enable-muxer=adts \
	--enable-libopencore-amrnb --enable-encoder=libopencore_amrnb --enable-decoder=libopencore_amrnb \
	--enable-libopencore-amrwb --enable-decoder=libopencore_amrwb \
	--enable-libvo_amrwbenc --enable-encoder=libvo_amrwbenc \
	--enable-decoder=amrnb --enable-decoder=amrwb \
	--enable-muxer=amr --enable-demuxer=amr \
	--enable-muxer=wav --enable-demuxer=wav \
	--enable-encoder=wavpack --enable-decoder=wavpack --enable-muxer=wv --enable-demuxer=wv \
	--enable-encoder=vorbis --enable-decoder=vorbis --enable-parser=vorbis \
	--enable-muxer=ogg --enable-demuxer=ogg \
	--enable-decoder=mp1float --enable-decoder=mp1 \
	--enable-encoder=mp2 --enable-decoder=mp2float --enable-encoder=mp2fixed --enable-decoder=mp2 --enable-muxer=mp2 \
	--enable-encoder=flac --enable-decoder=flac --enable-muxer=flac --enable-demuxer=flac --enable-parser=flac \
	--enable-encoder=ac3_fixed --enable-decoder=atrac3 --enable-decoder=atrac3p \
	--enable-encoder=eac3 --enable-decoder=eac3 --enable-muxer=eac3 --enable-demuxer=eac3 \
	--enable-encoder=wmav1 --enable-decoder=wmav1 \
	--enable-encoder=wmav2 --enable-decoder=wmav2 \
	--enable-demuxer=xwma \
	--enable-muxer=asf --enable-demuxer=asf \
	--enable-muxer=avi --enable-demuxer=avi \
	--enable-encoder=bmp --enable-decoder=bmp --enable-parser=bmp \
	--enable-encoder=png --enable-decoder=png --enable-parser=png \
	--enable-decoder=mjpeg --enable-encoder=mjpeg --enable-muxer=mjpeg --enable-demuxer=mjpeg \
	--enable-encoder=jpeg2000 --enable-encoder=jpegls --enable-decoder=jpeg2000 --enable-decoder=jpegls --enable-decoder=mjpegb \
	--enable-muxer=image2 --enable-demuxer=image2 \
	--enable-filter=scale \
	--enable-filter=afade \
	--enable-filter=asetrate \
	--enable-filter=atempo \
	--enable-swscale --enable-swscale-alpha \
	--enable-parser=mpegaudio \
	--enable-filter=aformat --enable-filter=anull --enable-filter=atrim --enable-filter=format --enable-filter=null --enable-filter=setpts --enable-filter=trim --enable-filter=aresample \
	--enable-avcodec --enable-avformat --enable-avutil --enable-swresample --enable-swscale --enable-avfilter \
	--enable-encoder=alac --enable-decoder=alac \
	--enable-encoder=adpcm_yamaha  --enable-decoder=adpcm_yamaha \
	--enable-muxer=mov --enable-demuxer=mov \
	--enable-demuxer=aiff --enable-muxer=aiff \
	--enable-muxer=mmf --enable-demuxer=mmf \
	--enable-decoder=ape --enable-demuxer=ape \
	--enable-decoder=mp3on4 --enable-decoder=mp3on4float \
	--enable-decoder=xma1 --enable-decoder=xma2 \
	--enable-decoder=mace3 --enable-decoder=mace6 \
	--enable-decoder=twinvq \
	--enable-decoder=mpc7 --enable-decoder=mpc8 --enable-decoder=tta \
	--enable-muxer=ipod \
	--enable-encoder=pcm_s16be --enable-decoder='pcm*' \

}

make_ffmpeg() {
	NPROC=$(grep -c ^processor /proc/cpuinfo)
	emmake make -j${NPROC}
}

#	-s SAFE_HEAP=1 \
#	-s ASSERTIONS=1 \
build_ffmpegjs() {
	emcc \
		-I. -I./fftools -I$BUILD_DIR/include \
		-Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -Llibpostproc -L${BUILD_DIR}/lib \
		-Qunused-arguments -Oz \
		-o dist/ffmpeg-video.js fftools/ffmpeg_opt.c fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/cmdutils.c fftools/ffmpeg.c \
		-lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lfdk-aac -lmp3lame -lopus -lshine -lz -lm \
		-lopencore-amrnb -lopencore-amrwb -lvo-aacenc -lvo-amrwbenc \
		--closure 1 \
		--pre-js prepend.js \
		-s EXPORT_NAME="'FFAudioModule'" \
		-s USE_SDL=2 \
		-s MODULARIZE=1 \
		-s SINGLE_FILE=1 \
		-s EXPORTED_FUNCTIONS="[_main, _metadata, _convert, _crop, _pitch]" \
		-s EXTRA_EXPORTED_RUNTIME_METHODS="[cwrap, FS, getValue, setValue]" \
		-s TOTAL_MEMORY=128MB \
		-s ALLOW_MEMORY_GROWTH=1
}

main() {
	install_package
#	build_zlib
#	build_fdk_aac
#	build_lame
#	build_amr
#	build_aacenc
#	build_amrwbenc
#	build_opus
#	build_shine
	configure_ffmpeg
	make_ffmpeg
	build_ffmpegjs
}

date
main "$@"
date
