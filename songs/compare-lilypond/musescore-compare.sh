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
# LINUX: CONFIRMED, now actually implemented -- see server/Dockerfile's
# MuseScore install step and server/library/jobs.py's pdf-mscore action,
# which run this same route inside the Docker web portal. The AppImage
# *does* bundle Qt's `offscreen` platform plugin, unlike this macOS .app,
# but that plugin doesn't actually work for MuseScore 4's CLI --
# `mscore4portable --platform offscreen -o out.pdf in.musicxml` still
# tries to initialize "xcb" and aborts, a known upstream regression
# (https://github.com/musescore/MuseScore/issues/17247). What actually
# works, verified against a real MuseScore 4 AppImage in a throwaway
# container: a virtual X server via `xvfb-run`, no special platform flag
# at all --
#
#     xvfb-run -a mscore4portable -o "$out" "$score_abs"
#
# no `open`/LaunchServices equivalent needed on Linux (that machinery is
# macOS-only, worked around here specifically because the .app must be
# launched as a real application, not just exec'd). Making *this* script
# cross-platform would mean branching on `uname`: macOS keeps the
# `open -W -a` path above, Linux uses `command -v mscore4portable` (or
# wherever it's installed) + `xvfb-run`. Not done here since this script
# is macOS-oriented (it launches the locally-installed .app); the Docker
# route above is where the Linux path actually lives and runs.
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
