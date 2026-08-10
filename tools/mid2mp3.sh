#!/bin/sh
# mid2mp3.sh -- render a MIDI file to MP3 using macOS's built-in General MIDI
# synth, no third-party synthesizer required. Compiles the sibling
# midirender.swift on first use (caching the binary in $TMPDIR), renders to a
# temporary WAV, then encodes MP3 with ffmpeg/LAME.
#
# Requirements: swiftc (Xcode command line tools) and ffmpeg built with
# libmp3lame. The instrument is the default GM piano.
#
# Usage: tools/mid2mp3.sh <input.mid> [output.mp3] [tailSeconds]
#        (output defaults to <input>.mp3; tailSeconds defaults to 2)
set -eu

here=$(cd "$(dirname "$0")" && pwd)
src="$here/midirender.swift"

in=${1:?usage: mid2mp3.sh <input.mid> [output.mp3] [tailSeconds]}
out=${2:-${in%.*}.mp3}
tail=${3:-2}

bin="${TMPDIR:-/tmp}/midirender.$(uname -m)"
if [ ! -x "$bin" ] || [ "$src" -nt "$bin" ]; then
  swiftc -O "$src" -o "$bin"
fi

wav="${TMPDIR:-/tmp}/mid2mp3.$$.wav"
trap 'rm -f "$wav"' EXIT
"$bin" "$in" "$wav" "$tail"
ffmpeg -hide_banner -loglevel error -y -i "$wav" -codec:a libmp3lame -q:a 5 "$out"
echo "wrote $out"
