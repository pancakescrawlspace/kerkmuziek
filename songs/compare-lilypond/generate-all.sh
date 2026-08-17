#!/bin/sh
# generate-all.sh -- regenerate every comparison artifact in this directory:
# LilyPond (via musicxml2ly), MuseScore 4 CLI, and Verovio-direct-to-PDF
# (bypassing scoryst/Typst) renders of four-voices and twinkle-fugue, plus
# a copy of the canonical scoryst/typst PDFs and a first-page PNG of every
# PDF here, for quick side-by-side comparison in an image viewer.
#
# Everything in this directory is gitignored except the scripts -- see
# .gitignore -- so nothing here is meant to be committed; rerun this after
# touching the MusicXML sources, or the comparison goes stale.
#
# Requires everything the individual scripts require: musicxml2ly + lilypond,
# MuseScore 4, tools/musicxml2pdf.sh's own deps (verovio Python package +
# rsvg-convert + pdfunite), and pdftoppm (poppler) for the PNG renders.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
mxml="$root/songs/musicxml"

"$here/lilypond-compare.sh" "$mxml/four-voices.musicxml" "$mxml/twinkle-fugue.musicxml"
"$here/musescore-compare.sh" "$mxml/four-voices.musicxml" "$mxml/twinkle-fugue.musicxml"
"$root/tools/musicxml2pdf.sh" "$mxml/four-voices.musicxml" "$here/four-voices-verovio-direct.pdf"
"$root/tools/musicxml2pdf.sh" "$mxml/four-voices.exploded.musicxml" "$here/four-voices-exploded-verovio-direct.pdf"
"$root/tools/musicxml2pdf.sh" "$mxml/twinkle-fugue.musicxml" "$here/twinkle-fugue-verovio-direct.pdf"

# the canonical pipelines' own output, copied here for side-by-side viewing
for name in four-voices twinkle-fugue; do
  cp "$root/songs/scoryst/$name.pdf" "$here/$name-scoryst.pdf"
  cp "$root/songs/typst/$name.pdf" "$here/$name-typst.pdf"
done

for pdf in "$here"/*.pdf; do
  pdftoppm -png -r 150 -f 1 -l 1 "$pdf" "${pdf%.pdf}"
done

echo "done -- see $here"
