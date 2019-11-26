
cat build-audio.sh | sed 's/emconfigure .\/configure/.\/configure/g' | sed 's/emmake make/make/g' | sed 's/EM_//g' | sed 's/disable-ffmpeg/enable-ffmpeg/g' | sed '/emcc/d' | sed '/em++/d' | sed '/emar/d' | sed '/llvm/d' | sed '/^\tbuild_ffmpegjs/d' > build-audio-exe.sh
