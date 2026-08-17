#!/bin/sh
# musescore-compare.sh -- render one or more MusicXML scores to PDF via
# MuseScore 4's CLI, for comparison against this project's scoryst/Typst
# pipeline. Writes <name>-musescore.pdf next to this script.
#
# MuseScore 4's mscore binary crashes on exit when exec'd directly
# (libc++abi: mutex lock failed) regardless of sandbox settings -- it can
# still write a correct PDF before crashing, but that's fragile to depend
# on, so this goes through `open`, which starts it as a proper LaunchServices
# app and waits for it to quit cleanly.
#
# Usage: songs/compare-lilypond/musescore-compare.sh <score.musicxml>...
#
# Requires MuseScore 4 installed at /Applications/MuseScore 4.app (macOS
# only -- no portable route was found; see tools/README.md's Dependencies
# section).
#
# NOT HEADLESS -- this needs a live WindowServer session and will not run
# over SSH into a Mac with nobody logged into the GUI (SSHing into a Mac
# that *does* have an active graphical session, even locked, still works,
# since the WindowServer is already running system-wide by then). Confirmed
# by inspecting the app bundle: `Contents/PlugIns/platforms/` ships only
# libqcocoa.dylib, no `offscreen`/`minimal` plugin, and
# QT_QPA_PLATFORM=offscreen fails outright ("Available platform plugins
# are: cocoa"). Nothing about *how* mscore is invoked changes that -- it's
# a property of this macOS build.
#
# LINUX ANALYSIS (untested -- no Linux machine available here): MuseScore's
# Linux distribution (AppImage or native package) bundles Qt's `offscreen`
# platform plugin, unlike this macOS .app, so the standard fix is simply:
#
#     QT_QPA_PLATFORM=offscreen mscore -o "$out" "$score_abs"
#
# run directly, no `open`/LaunchServices equivalent needed (that machinery
# is macOS-only, worked around here specifically because the .app must be
# launched as a real application, not just exec'd). If a given Linux
# install turns out not to have the offscreen plugin after all, the
# fallback used across the MuseScore community is a virtual framebuffer:
# `xvfb-run mscore -o "$out" "$score_abs"` (needs Xvfb installed; heavier
# and slower than offscreen since it spins up a real, if virtual, X
# server). Making this script cross-platform would mean branching on
# `uname`: macOS keeps the `open -W -a` path above, Linux uses
# `command -v mscore` + QT_QPA_PLATFORM=offscreen (falling back to
# xvfb-run only if that's confirmed necessary). Left as analysis, not
# implemented, since it can't be verified without a Linux box to test
# against.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
app="/Applications/MuseScore 4.app"

for score in "$@"; do
  name=$(basename "$score" .musicxml)
  score_abs=$(cd "$(dirname "$score")" && pwd)/$(basename "$score")
  out="$here/$name-musescore.pdf"
  open -W -a "$app" --args -o "$out" "$score_abs"
  echo "wrote $out"
done
