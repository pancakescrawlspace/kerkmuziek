#!/bin/sh
# render-all.sh -- (re)generate the canonical MP3s in songs/scoryst from the
# MusicXML scores: a piano render of every piece, plus a choir render of the
# choral pieces (four-voices, twinkle-fugue). Portable -- it drives FluidSynth
# via score2mp3.sh, so it runs anywhere with fluidsynth + a soundfont + ffmpeg +
# python-verovio (Linux, macOS, WSL).
#
# Soundfont: uses $SOUNDFONT if set, otherwise the autodetection in
# mid2mp3-fluidsynth.sh (e.g. FluidR3_GM from the fluid-soundfont-gm package on
# Linux). Because different soundfonts produce different audio, a rebuild on a
# machine with a different soundfont will show the .mp3 files as changed -- that
# is expected.
#
# The soundfont-comparison renders (*.choir-chorium.mp3 etc.) are exploration
# artifacts and are intentionally NOT regenerated here.
#
# Usage: tools/render-all.sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
songs=$(cd "$here/.." && pwd)/songs/scoryst
s2m="$here/score2mp3.sh"

# Every piece gets a piano render; the choral pieces also get a choir render.
ALL="four-voices twinkle-fugue parallel-fifths-octaves hidden-fifths-octaves unequal-fifths"
CHORAL="four-voices twinkle-fugue"

for b in $ALL; do
  echo ">> $b.mp3 (piano)"
  "$s2m" "$songs/$b.musicxml" "$songs/$b.mp3"
done

for b in $CHORAL; do
  echo ">> $b.choir.mp3 (Choir Aahs)"
  "$s2m" -p 53 "$songs/$b.musicxml" "$songs/$b.choir.mp3"
done

echo "done -- rebuilt $(echo $ALL | wc -w) piano + $(echo $CHORAL | wc -w) choir renders."
