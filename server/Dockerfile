# syntax=docker/dockerfile:1
# Build from the repo root: docker compose (see ../docker-compose.yml)
# passes context: .. so this can COPY the whole repo, not just server/ --
# the regenerate actions in library/jobs.py shell out to ../tools/*.sh|py
# against ../songs/, both of which need to be present (and, at runtime,
# bind-mounted so writes land back on the host -- see docker-compose.yml).
FROM python:3.14-slim

# fluidsynth + ffmpeg cover score2mp3.sh / mid2mp3-fluidsynth.sh (MIDI -> MP3);
# curl + xz-utils are only needed to fetch typst/MuseScore/the soundfont
# below; the rest (xvfb onward) are what MuseScore's AppImage needs at
# runtime -- see the MuseScore install step further down for why.
RUN apt-get update && apt-get install -y --no-install-recommends \
        fluidsynth \
        ffmpeg \
        curl \
        xz-utils \
        ca-certificates \
        xvfb \
        xauth \
        libasound2 \
        libpipewire-0.3-0t64 \
        libgl1 \
        libglx0 \
        libopengl0 \
        libegl1 \
        libfontconfig1 \
        libx11-6 \
        libglib2.0-0t64 \
        libfreetype6 \
        libgpg-error0 \
    && rm -rf /var/lib/apt/lists/*

# typst -- prebuilt static (musl) binary, runs fine on this glibc image.
# Pinned to match the version this project was developed against
# (`typst --version`); bump deliberately, not as a side effect.
# TARGETARCH is set automatically by BuildKit (amd64/arm64) -- without
# mapping it to typst's own asset naming, this would silently install the
# wrong-architecture binary and only work via emulation (slow, and not
# guaranteed to be available at all on every host).
ARG TYPST_VERSION=0.15.1
ARG TARGETARCH
RUN case "$TARGETARCH" in \
        amd64) typst_arch=x86_64 ;; \
        arm64) typst_arch=aarch64 ;; \
        *) echo "unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/typst.tar.xz \
        "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-${typst_arch}-unknown-linux-musl.tar.xz" \
    && tar -xJf /tmp/typst.tar.xz -C /tmp \
    && mv "/tmp/typst-${typst_arch}-unknown-linux-musl/typst" /usr/local/bin/typst \
    && rm -rf /tmp/typst.tar.xz "/tmp/typst-${typst_arch}-unknown-linux-musl"

# MuseScore 4 -- for the pdf-mscore action, a route independent of Typst
# entirely (reads the MusicXML directly, no .typ wrapper -- so unlike
# pdf-scoryst/pdf-typst it renders bare notation only, no title/commentary
# text, and is available for every MusicXML file, not just ones with a
# matching .typ). No Debian package for MuseScore 4 exists, so this is the
# official Linux AppImage, extracted at build time (same reasoning as
# typst: --appimage-extract avoids needing FUSE, which this container
# doesn't have, to run an AppImage directly).
#
# `mscore4portable --platform offscreen` -- the thing you'd expect to use
# for headless export -- is a known-broken MuseScore 4 regression
# (https://github.com/musescore/MuseScore/issues/17247): it still tries to
# initialize the "xcb" platform and aborts. `xvfb-run` (a real, virtual X
# server) is the actual working approach, empirically confirmed here and
# matching what other people running MuseScore 4 in Docker landed on too;
# see server/README.md's Docker notes and songs/compare-lilypond/
# musescore-compare.sh, whose own header comment previously guessed
# offscreen would work on Linux -- it doesn't, this does.
# MSCORE_TAG is the release tag (github.com/musescore/MuseScore/releases);
# MSCORE_VERSION is the exact string the asset filename uses, which -- for
# no documented reason -- has a 4th, build-number component MSCORE_TAG
# doesn't. Check the actual release's asset names when bumping either.
ARG MSCORE_TAG=4.7.4
ARG MSCORE_VERSION=4.7.4.260706075
RUN case "$TARGETARCH" in \
        amd64) mscore_arch=x86_64 ;; \
        arm64) mscore_arch=aarch64 ;; \
        *) echo "unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/mscore.AppImage \
        "https://github.com/musescore/MuseScore/releases/download/v${MSCORE_TAG}/MuseScore-Studio-${MSCORE_VERSION}-${mscore_arch}.AppImage" \
    && chmod +x /tmp/mscore.AppImage \
    && cd /tmp && ./mscore.AppImage --appimage-extract >/dev/null \
    && mv /tmp/squashfs-root /opt/musescore \
    && rm -f /tmp/mscore.AppImage

# General MIDI soundfont -- same one tools/README.md documents fetching by
# hand into ~/soundfonts; mid2mp3-fluidsynth.sh autodetects this exact path,
# but SOUNDFONT is also set explicitly below so that doesn't have to hold.
RUN mkdir -p /root/soundfonts && curl -fsSL -o /root/soundfonts/GeneralUser-GS.sf2 \
        https://raw.githubusercontent.com/mrbumpy409/GeneralUser-GS/main/GeneralUser-GS.sf2
ENV SOUNDFONT=/root/soundfonts/GeneralUser-GS.sf2

# songs/scoryst/*.typ and songs/typst/*.typ set `#set text(font: "Helvetica")`
# -- fine on macOS, where Helvetica ships as a system font, but Typst's
# system font scan (which compile-scores.sh and jobs.py's `typst compile`
# both rely on -- neither passes --font-path for this) finds nothing named
# that on Linux and silently substitutes something else. TeX Gyre Heros is
# a metric-compatible Helvetica clone (GUST Font License, an OFL variant
# that explicitly allows this); renaming its internal name records to
# "Helvetica" is the standard, tool-agnostic way to make name-based font
# lookup resolve it, matching how songs/typst/fonts/Leipzig.ttf's own
# naming was handled. Not committed to the repo -- fetched and renamed at
# build time, same as typst and the soundfont above.
RUN pip install --no-cache-dir fonttools \
    && mkdir -p /usr/share/fonts/helvetica \
    && python3 <<'PY'
import urllib.request
from fontTools.ttLib import TTFont

FACES = {
    "regular": ("Helvetica", "Regular", "Helvetica", "Helvetica"),
    "bold": ("Helvetica", "Bold", "Helvetica Bold", "Helvetica-Bold"),
    "italic": ("Helvetica", "Italic", "Helvetica Italic", "Helvetica-Italic"),
    "bolditalic": ("Helvetica", "Bold Italic", "Helvetica Bold Italic", "Helvetica-BoldItalic"),
}
for face, (family, subfamily, full, ps) in FACES.items():
    src = f"/tmp/{face}.otf"
    urllib.request.urlretrieve(
        f"https://mirrors.ctan.org/fonts/tex-gyre/opentype/texgyreheros-{face}.otf", src
    )
    font = TTFont(src)
    names = font["name"]
    for name_id, value in ((1, family), (2, subfamily), (4, full), (6, ps), (16, family), (17, subfamily)):
        names.setName(value, name_id, 3, 1, 0x409)  # Windows, English (US)
        names.setName(value, name_id, 1, 0, 0)  # Mac, Roman
    font.save(f"/usr/share/fonts/helvetica/{face}.otf")
PY
RUN pip uninstall -y fonttools

WORKDIR /app

COPY server/requirements.txt server/requirements.txt
RUN pip install --no-cache-dir -r server/requirements.txt verovio

# The rest of the repo: tools/*.sh|py and songs/*.typ that the regenerate
# actions call/compile, plus the scoryst *.typ's Typst package import
# (below) needs actual files to compile against. Overridden at runtime by
# docker-compose.yml's bind mount -- this COPY only matters for the package
# cache warmed just below, and as a fallback if the image is run without it.
COPY . .

# scoryst is fetched from Typst's package registry on first compile --
# fetch it now (needs network at build time) so pdf-scoryst jobs don't hit
# the registry, or fail offline, on first use at runtime.
RUN typst compile --root . songs/scoryst/four-voices.typ /tmp/warm.pdf && rm -f /tmp/warm.pdf

WORKDIR /app/server
EXPOSE 8000
CMD ["sh", "-c", "python manage.py migrate --noinput && python manage.py runserver 0.0.0.0:8000"]
