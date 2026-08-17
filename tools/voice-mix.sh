#!/bin/sh
# voice-mix.sh -- render a MusicXML score to MP3 with one voice spotlighted
# louder than the rest, for studying your part while still hearing the
# others. Wraps: MusicXML -> MIDI with per-part MIDI channels + Channel
# Volume (voice-mix.py) -> WAV -> MP3 (mid2mp3-fluidsynth.sh, FluidSynth +
# ffmpeg).
#
# Run tools/voice-explode.py first if the voice you want to spotlight shares
# a part (staff) with another voice -- Verovio assigns one MIDI channel per
# <part>, not per <voice>, so per-voice volume needs one part per voice.
#
# Usage: tools/voice-mix.sh [-p GM_PROGRAM] <score.musicxml> <output.mp3> \
#          <spotlight-voice> [spotlight-volume=127] [background-volume=40]
#   -p N    General MIDI program for every part, 1-based (default 1 piano;
#           e.g. 53 Choir Aahs).
#   <spotlight-voice>  a <part-name> label (matched case-insensitively) or an
#           explicit <part-id>, as in voice-isolate.py.
#   volumes are MIDI Channel Volume values, 0-127 (default 127 spotlight, 40
#   background -- roughly a 32 dB spread with this project's FluidSynth
#   rendering).
#
# Example:
#   python3 tools/voice-explode.py songs/musicxml/four-voices.musicxml /tmp/exploded.musicxml
#   tools/voice-mix.sh /tmp/exploded.musicxml soprano-mix.mp3 soprano
#
# Env:
#   SOUNDFONT=/path/to.sf2   pick the soundfont (else autodetected; see
#                            mid2mp3-fluidsynth.sh)
#
# Requirements: python3 with the `verovio` and `mido` packages
# (`pip install verovio mido`), fluidsynth (+ a .sf2 soundfont), and ffmpeg
# with libmp3lame.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
usage="usage: voice-mix.sh [-p GM_PROGRAM] <score.musicxml> <output.mp3> <spotlight-voice> [spotlight-volume=127] [background-volume=40]"

prog=1
while getopts "p:" opt; do
  case "$opt" in
    p) prog=$OPTARG ;;
    *) echo "$usage" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

score=${1:?$usage}
out=${2:?$usage}
spotlight=${3:?$usage}
spot_vol=${4:-127}
bg_vol=${5:-40}

mid="${TMPDIR:-/tmp}/voice-mix.$$.mid"
trap 'rm -f "$mid"' EXIT

python3 "$here/voice-mix.py" "$score" "$mid" "$spotlight" "$spot_vol" "$bg_vol" "$prog"
"$here/mid2mp3-fluidsynth.sh" "$mid" "$out"
