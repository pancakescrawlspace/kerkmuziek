#!/bin/sh
# compile-scores.sh -- compile the scoryst Typst scores to PDF with the correct
# project root. The scores live in songs/scoryst/*.typ but read their notes from
# songs/musicxml/*.musicxml, i.e. from OUTSIDE their own directory. Typst
# sandboxes file reads to the project root, so a bare `typst compile foo.typ`
# (whose default root is the file's own folder) would reject the `../musicxml/`
# read. This wrapper sets `--root` to the repo root so the read resolves.
#
# Usage:
#   tools/compile-scores.sh                       # compile every songs/scoryst/*.typ
#   tools/compile-scores.sh songs/scoryst/foo.typ # compile just the given file(s)
#
# Each PDF is written next to its .typ (foo.typ -> foo.pdf), matching the
# committed layout. Requires `typst`.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)

if [ "$#" -eq 0 ]; then
  set -- "$root"/songs/scoryst/*.typ
fi

for typ in "$@"; do
  pdf="${typ%.typ}.pdf"
  echo ">> $(basename "$pdf")"
  typst compile --root "$root" "$typ" "$pdf"
done

echo "done -- compiled $# score(s)."
