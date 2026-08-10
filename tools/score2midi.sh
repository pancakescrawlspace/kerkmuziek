#!/bin/sh
# score2midi.sh -- export a MusicXML score to a Standard MIDI File. This is how
# the committed songs/scoryst/*.mid were made: Verovio's renderToMIDI (the same
# conversion score2mp3.sh runs before handing off to FluidSynth). Portable:
# works anywhere Python + the `verovio` package is installed (Linux/macOS/WSL).
#
# Usage: tools/score2midi.sh [-p GM_PROGRAM] <score.musicxml> [output.mid]
#   -p N   General MIDI program, 1-based (e.g. 53 Choir Aahs, 54 Voice Oohs).
#          Injects the instrument into a copy of the score via choirify.py;
#          the file on disk is untouched. Omit to keep whatever the score
#          specifies (piano by default).
#   output defaults to <score>.mid
#
# To (re)generate the committed MIDI next to its artifacts, name the output
# explicitly, e.g.:
#   tools/score2midi.sh songs/musicxml/twinkle-fugue.musicxml \
#     songs/scoryst/twinkle-fugue.mid
#
# Requirements: python3 with the `verovio` package (`pip install verovio`).
set -eu

here=$(cd "$(dirname "$0")" && pwd)

prog=""
while getopts "p:" opt; do
  case "$opt" in
    p) prog=$OPTARG ;;
    *) echo "usage: score2midi.sh [-p GM_PROGRAM] <score.musicxml> [output.mid]" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

score=${1:?usage: score2midi.sh [-p GM_PROGRAM] <score.musicxml> [output.mid]}
out=${2:-${score%.*}.mid}

if [ -n "$prog" ]; then
  python3 "$here/choirify.py" "$score" "$out" "$prog" >/dev/null
else
  python3 - "$score" "$out" <<'PY'
import sys, base64, verovio
tk = verovio.toolkit()
assert tk.loadFile(sys.argv[1]), "verovio failed to load " + sys.argv[1]
open(sys.argv[2], "wb").write(base64.b64decode(tk.renderToMIDI()))
PY
fi

echo "wrote $out"
