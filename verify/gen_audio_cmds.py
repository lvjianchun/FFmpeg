#!/usr/bin/python3

all_encoders = ["libmp3lame", "libshine", "pcm_s16le", "flac", "aac", "libfdk_aac", "vorbis", "alac", "wmav2", "wmav1", "libopus", "pcm_s16be", "libopencore_amrnb", "libvo_amrwbenc", "eac3", "wavpack"]

format_to_encoders = { 
    "MP3": ["libmp3lame", "libshine"],
    "WAV":["pcm_s16le"],
    "FLAC":["flac"],
    "AAC":["aac", "libfdk_aac"],
    "OGG":["flac", "vorbis"],
    "M4A":["alac", "libfdk_aac", "aac"],
    "M4R":["aac", "libfdk_aac"],
    "WMA":["wmav2", "wmav1"],
    "OPUS":["libopus"],
    "AIFF":["pcm_s16be"],
    "MMF":["adpcm_yamaha"],
    "ALAC":["alac"],
    "AMR":["libopencore_amrnb", "libvo_amrwbenc"],
    "EAC3":["eac3"],
    "WV":["wavpack"],
}

default_sample_rates = ["48000", "44100", "32000", "24000", "22050", "16000", "12000", "11025", "8000"]

bit_rates = ["256k", "160k", "128k", "96k", "80k", "64k", "48k"]

def getSampleRate(encoder):
    if encoder == "adpcm_yamaha":
        return ["44100", "22050", "11025", "8000", "4000"];
    if encoder == "libopus":
        return ["48000", "16000", "12000", "8000"];
    if encoder == "libshine":
        return ["48000", "44100"];
    if encoder == "libopencore_amrnb":
        return ["8000"];
    if encoder == "libvo_amrwbenc":
        return ["16000"];
    if encoder == "eac3":
        return ["48000", "44100", "32000"];

    return default_sample_rates;


for f in format_to_encoders:
  for encoder in format_to_encoders[f]:
    for srate in getSampleRate(encoder):
      for brate in bit_rates:
        f = f.lower()
        # print(f.lower() + "\t" + encoder + "\t" + srate + "\t" + brate)
        prefix = "./ffmpeg -i input.flac "
        args = " -ab " + brate + " -ar " + srate + " -acodec " + encoder
        # amr only support mono
        if f == "amr":
          args = args + " -ac 1 "
        else:
          args = args + " -ac 2 "
        # other formats
        if f == "m4r" or f == "alac":
          args = args + " -f ipod "
        if f == "wv":
          args = args + " -f wv "
        if encoder == "vorbis" or encoder == "adpcm_yamaha":
          args = args + " -strict -2 "
        postfix = " output/" + encoder + "_" + brate + "_" + srate + "." + f
        log = " log/" + encoder + "_" + brate + "_" + srate + "_" + f + ".log"
        print(prefix + args + postfix + " > " + log + " 2>&1")
