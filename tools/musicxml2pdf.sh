#!/bin/sh
# musicxml2pdf.sh -- render a MusicXML score straight to a PDF with real,
# uniform pages (A4 by default) -- no Typst, no scoryst, no MuseScore.
# Calls musicxml2svg.py for the MusicXML -> SVG step (one SVG per page),
# then librsvg's rsvg-convert turns each into a one-page PDF, and poppler's
# pdfunite stitches them into the final multi-page PDF.
#
# musicxml2svg.py's own default (adjustPageHeight=true) crops each page
# tightly to its own content, which is exactly right for embedding as a
# Typst image (see musicxml2svg.py's docstring) but wrong here: it gives
# every page a different size, with no single fixed page for rsvg-convert
# to target. This script overrides that back to Verovio's own default (a
# real, fixed page -- 210mm x 297mm, i.e. A4, unless overridden via extra
# --option flags) so every page comes out uniform.
#
# Verovio's SVG width/height are in its own drawing units, 10 per mm (so
# a "2100px" SVG page means 210mm, not 2100 CSS pixels at the usual
# 96dpi) -- rsvg-convert doesn't know that convention, so it must be told
# to render at 254dpi (25.4mm/inch * 10 units/mm) for the units to come
# out at their true physical size; at the default 96dpi the same SVG
# renders about 2.6x too large and an "A4" page comes out as
# ~1575x2227pt instead of the true 595x842pt.
#
# Usage: tools/musicxml2pdf.sh <input.musicxml> [output.pdf] [--option key=value ...]
#   output defaults to <input>.pdf
#   --option is forwarded to musicxml2svg.py (e.g. --option lyricWordSpace=1.6)
#
# Requires: everything musicxml2svg.py requires (the `verovio` Python
# package), plus `rsvg-convert` (librsvg) and `pdfunite` (poppler) on PATH.
set -eu

here=$(cd "$(dirname "$0")" && pwd)

in=${1:?usage: musicxml2pdf.sh <input.musicxml> [output.pdf] [--option key=value ...]}
shift
out="${in%.*}.pdf"
if [ $# -gt 0 ] && [ "$1" != "--option" ]; then
  out=$1
  shift
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

python3 "$here/musicxml2svg.py" "$in" "$tmp/page" --option adjustPageHeight=false "$@"

n=$(cat "$tmp/page.pages")

i=1
while [ "$i" -le "$n" ]; do
  rsvg-convert -f pdf -d 254 -p 254 -o "$tmp/page-$i.pdf" "$tmp/page-$i.svg"
  i=$((i + 1))
done

if [ "$n" -eq 1 ]; then
  mv "$tmp/page-1.pdf" "$out"
else
  i=1
  set --
  while [ "$i" -le "$n" ]; do
    set -- "$@" "$tmp/page-$i.pdf"
    i=$((i + 1))
  done
  pdfunite "$@" "$out"
fi

echo "wrote $out"
