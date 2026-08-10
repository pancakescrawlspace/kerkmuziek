#!/bin/sh
# render-all.sh -- (re)generate the canonical MP3s in songs/audio from the
# MusicXML scores in songs/musicxml: a piano render of every piece, plus a choir render of the
# choral pieces (four-voices, twinkle-fugue). Portable -- it drives FluidSynth
# via score2mp3.sh, so it runs anywhere with fluidsynth + a soundfont + ffmpeg +
# python-verovio (Linux, macOS, WSL).
#
# Soundfonts (env; autodetected via mid2mp3-fluidsynth.sh if unset):
#   SOUNDFONT         soundfont for the piano renders
#   SOUNDFONT_CHOIR   soundfont for the choir renders (default: $SOUNDFONT)
# The committed set was made with SOUNDFONT=GeneralUser GS
# (https://github.com/mrbumpy409/GeneralUser-GS) and SOUNDFONT_CHOIR=MuseScore
# General (https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/).
# Because different soundfonts produce different audio, a rebuild on a machine
# with a different soundfont will show the .mp3 files as changed -- that is
# expected.
#
# The soundfont-comparison renders (*.choir-chorium.mp3 etc.) are exploration
# artifacts and are intentionally NOT regenerated here.
#
# Usage: tools/render-all.sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
scores="$root/songs/musicxml"   # MusicXML sources live here
songs="$root/songs/audio"       # generated MP3s are written here
s2m="$here/score2mp3.sh"

# Every piece gets a piano render; the choral pieces also get a choir render.
ALL="four-voices twinkle-fugue parallel-fifths-octaves hidden-fifths-octaves unequal-fifths"
CHORAL="four-voices twinkle-fugue"

for b in $ALL; do
  echo ">> $b.mp3 (piano)"
  "$s2m" "$scores/$b.musicxml" "$songs/$b.mp3"
done

for b in $CHORAL; do
  echo ">> $b.choir.mp3 (Choir Aahs)"
  if [ -n "${SOUNDFONT_CHOIR:-}" ]; then
    SOUNDFONT="$SOUNDFONT_CHOIR" "$s2m" -p 53 "$scores/$b.musicxml" "$songs/$b.choir.mp3"
  else
    "$s2m" -p 53 "$scores/$b.musicxml" "$songs/$b.choir.mp3"
  fi
done

echo "done -- rebuilt $(echo $ALL | wc -w) piano + $(echo $CHORAL | wc -w) choir renders."
