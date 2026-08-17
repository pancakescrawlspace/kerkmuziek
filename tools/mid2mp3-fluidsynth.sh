#!/bin/sh
# mid2mp3-fluidsynth.sh -- portable MIDI -> MP3 using FluidSynth + a soundfont,
# then ffmpeg/LAME. Works anywhere FluidSynth and ffmpeg are installed
# (Linux, macOS, Windows/WSL) -- the portable counterpart to the macOS-only
# mid2mp3.sh (which uses the system's built-in synth via Swift).
#
# Install FluidSynth, a General MIDI soundfont, and ffmpeg:
#   Debian/Ubuntu: sudo apt install fluidsynth fluid-soundfont-gm ffmpeg
#   Fedora:        sudo dnf install fluidsynth fluid-soundfont-gm ffmpeg
#   Arch:          sudo pacman -S fluidsynth soundfont-fluid ffmpeg
#   macOS (brew):  brew install fluid-synth ffmpeg   # then fetch a .sf2 (below)
#   macOS (port):  sudo port install fluidsynth ffmpeg
#
# A good free soundfont is FluidR3_GM.sf2 (the fluid-soundfont-gm package on
# Linux installs it under /usr/share/sounds/sf2/). On macOS, drop a .sf2 into
# ~/soundfonts and it is autodetected; this repo's canonical piano soundfont is
# GeneralUser-GS.sf2 (https://github.com/mrbumpy409/GeneralUser-GS). Or point
# SOUNDFONT at any .sf2/.sf3 explicitly, e.g.
#   SOUNDFONT=~/soundfonts/GeneralUser-GS.sf2 tools/mid2mp3-fluidsynth.sh foo.mid
#
# Usage: tools/mid2mp3-fluidsynth.sh <input.mid> [output.mp3]
#        (output defaults to <input>.mp3; set SOUNDFONT to override autodetect)
set -eu

in=${1:?usage: mid2mp3-fluidsynth.sh <input.mid> [output.mp3]}
out=${2:-${in%.*}.mp3}

# Locate a .sf2 soundfont unless SOUNDFONT is set.
sf=${SOUNDFONT:-}
if [ -z "$sf" ]; then
  for c in \
    "$HOME"/soundfonts/GeneralUser-GS.sf2 \
    "$HOME"/soundfonts/*.sf2 \
    /usr/share/sounds/sf2/FluidR3_GM.sf2 \
    /usr/share/sounds/sf2/default-GM.sf2 \
    /usr/share/soundfonts/FluidR3_GM.sf2 \
    /usr/share/soundfonts/default.sf2 \
    /opt/homebrew/share/fluidsynth/*.sf2 \
    /usr/local/share/fluidsynth/*.sf2 \
    /opt/local/share/sounds/sf2/*.sf2 ; do
    [ -f "$c" ] && { sf="$c"; break; }
  done
fi
[ -n "$sf" ] || { echo "no .sf2 soundfont found -- set SOUNDFONT=/path/to.sf2" >&2; exit 1; }

# Render to a temp WAV (needs a FluidSynth built with libsndfile -- the norm on
# packaged builds), then encode MP3. -g caps the gain to avoid clipping.
wav="${TMPDIR:-/tmp}/mid2mp3.$$.wav"
trap 'rm -f "$wav"' EXIT
fluidsynth -ni -g 0.8 -r 44100 -F "$wav" "$sf" "$in"
ffmpeg -hide_banner -loglevel error -y -i "$wav" -codec:a libmp3lame -q:a 2 "$out"
echo "wrote $out  (soundfont: $sf)"
