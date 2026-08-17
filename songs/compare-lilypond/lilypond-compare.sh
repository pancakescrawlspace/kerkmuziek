#!/bin/sh
# lilypond-compare.sh -- render one or more MusicXML scores to PDF via
# LilyPond's bundled musicxml2ly, for comparison against this project's
# scoryst/Typst pipeline (../scoryst/, ../typst/) and against MusicFormats'
# xml2ly (../../tools/xml2ly.sh). Writes <name>-lilypond.ly and
# <name>-lilypond.pdf next to this script.
#
# Usage: songs/compare-lilypond/lilypond-compare.sh <score.musicxml>...
#
# Requires `musicxml2ly` and `lilypond` on PATH (e.g. MacPorts:
# sudo port install lilypond).
set -eu

here=$(cd "$(dirname "$0")" && pwd)

for score in "$@"; do
  name=$(basename "$score" .musicxml)
  musicxml2ly -o "$here/$name-lilypond.ly" "$score"
  lilypond -o "$here/$name-lilypond" "$here/$name-lilypond.ly"
  echo "wrote $here/$name-lilypond.ly and .pdf"
done
