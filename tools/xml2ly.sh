#!/bin/sh
# xml2ly.sh -- export a MusicXML score to LilyPond format via xml2ly, the
# musicxml2lilypond converter from the MusicFormats project
# (https://github.com/jacques-menu/musicformats). This is a different
# implementation than the musicxml2ly script bundled with LilyPond itself
# (used ad hoc for the songs/compare-lilypond/ comparison) -- xml2ly is a
# separate C++ tool with its own option set, potentially handling more of
# MusicXML's feature surface.
#
# xml2ly is NOT vendored in this repo: it's a single-platform ~25MB binary,
# which doesn't fit how this project treats external engraving tools
# (typst, lilypond, fluidsynth, MuseScore are all expected to be installed
# by the user, not checked in). Install it yourself and put it on PATH:
#   1. Download the release ZIP for your OS from
#      https://github.com/jacques-menu/musicformats/releases
#      (e.g. musicformats-macos-vX.Y.zip for macOS)
#   2. Extract bin/xml2ly and put it on PATH, e.g.:
#        unzip -j musicformats-macos-*.zip '*/bin/xml2ly' -d ~/bin
#   The macOS build is statically linked against libc++/libSystem only
#   (verified via otool -L), so lib/*.a and lib/*.dylib from the same
#   release are not needed -- just the bin/xml2ly executable.
#
# Usage: tools/xml2ly.sh <score.musicxml> [output.ly]
#   output defaults to <score>.ly
#
# Example:
#   tools/xml2ly.sh songs/musicxml/four-voices.musicxml /tmp/four-voices.ly
#   lilypond -o /tmp /tmp/four-voices.ly
#
# Requires xml2ly on PATH.
set -eu

command -v xml2ly >/dev/null 2>&1 || {
  echo "xml2ly not found on PATH -- see this script's header comment for install instructions" >&2
  exit 1
}

score=${1:?usage: xml2ly.sh <score.musicxml> [output.ly]}
out=${2:-${score%.*}.ly}

xml2ly "$score" -o "$out"
echo "wrote $out"
