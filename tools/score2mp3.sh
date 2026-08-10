#!/bin/sh
# score2mp3.sh -- render a MusicXML score straight to MP3 in one step, optionally
# with a chosen General MIDI instrument. Wraps: MusicXML -> MIDI (Verovio,
# via choirify.py when an instrument is requested) -> WAV (FluidSynth) -> MP3
# (ffmpeg/LAME). Portable: works anywhere Python+verovio, fluidsynth and ffmpeg
# are installed (Linux, macOS, WSL).
#
# Usage: tools/score2mp3.sh [-p GM_PROGRAM] <score.musicxml> [output.mp3]
#   -p N   General MIDI program, 1-based (e.g. 53 Choir Aahs, 54 Voice Oohs).
#          Omit to keep whatever the score specifies (piano by default).
#   output defaults to <score>.mp3
#
# Env:
#   SOUNDFONT=/path/to.sf2   pick the soundfont (else autodetected; see
#                            mid2mp3-fluidsynth.sh)
#
# Requirements: python3 with the `verovio` package, fluidsynth (+ a .sf2
# soundfont), and ffmpeg with libmp3lame.
set -eu

here=$(cd "$(dirname "$0")" && pwd)

prog=""
while getopts "p:" opt; do
  case "$opt" in
    p) prog=$OPTARG ;;
    *) echo "usage: score2mp3.sh [-p GM_PROGRAM] <score.musicxml> [output.mp3]" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

score=${1:?usage: score2mp3.sh [-p GM_PROGRAM] <score.musicxml> [output.mp3]}
out=${2:-${score%.*}.mp3}

mid="${TMPDIR:-/tmp}/score2mp3.$$.mid"
trap 'rm -f "$mid"' EXIT

if [ -n "$prog" ]; then
  python3 "$here/choirify.py" "$score" "$mid" "$prog" >/dev/null
else
  python3 - "$score" "$mid" <<'PY'
import sys, base64, verovio
tk = verovio.toolkit()
assert tk.loadFile(sys.argv[1]), "verovio failed to load " + sys.argv[1]
open(sys.argv[2], "wb").write(base64.b64decode(tk.renderToMIDI()))
PY
fi

"$here/mid2mp3-fluidsynth.sh" "$mid" "$out"
