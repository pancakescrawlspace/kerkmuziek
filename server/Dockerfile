# syntax=docker/dockerfile:1
# Build from the repo root: docker compose (see ../docker-compose.yml)
# passes context: .. so this can COPY the whole repo, not just server/ --
# the regenerate actions in library/jobs.py shell out to ../tools/*.sh|py
# against ../songs/, both of which need to be present (and, at runtime,
# bind-mounted so writes land back on the host -- see docker-compose.yml).
FROM python:3.14-slim

# fluidsynth + ffmpeg cover score2mp3.sh / mid2mp3-fluidsynth.sh (MIDI -> MP3);
# curl + xz-utils are only needed to fetch typst and the soundfont below.
RUN apt-get update && apt-get install -y --no-install-recommends \
        fluidsynth \
        ffmpeg \
        curl \
        xz-utils \
        ca-certificates \
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
