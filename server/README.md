# pitchmarks web portal

A local Django app that browses `songs/` (MusicXML, MIDI, MP3, PDF) and
lets you re-run the `tools/` scripts from a browser instead of the
terminal. Personal, localhost-only tool -- no login system.

## Setup

Either a local venv:

```sh
cd server
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python manage.py migrate
.venv/bin/python manage.py runserver
```

or Docker Compose, from the repo root (builds fluidsynth/ffmpeg/typst/a
soundfont into the image -- see `Dockerfile` -- and bind-mounts the whole
repo so regenerated files land back on disk, not inside the container):

```sh
docker compose up      # http://127.0.0.1:8000/, Ctrl-C to stop
docker compose up -d   # same, detached
docker compose down    # stop and remove the container
```

Either way, open <http://127.0.0.1:8000/>. Right-click a row in the
MusicXML or MIDI tab for the actions available on it.

## What it does, and doesn't, cover

The four tabs are live directory listings (`songs/musicxml`, `songs/audio`
split into MIDI/MP3, and `songs/scoryst` + `songs/typst` together for PDF)
-- there's no database of files, so anything dropped into those directories
by hand shows up too.

Regenerate actions are the one-step defaults only: `score2midi.sh`,
`score2mp3.sh`, `compile-scores.sh` (scoryst PDF), `musicxml2svg.py` +
`typst compile` (typst PDF), and `mid2mp3-fluidsynth.sh`. The PDF actions
only appear for a MusicXML file that already has a matching
`songs/scoryst/<name>.typ` / `songs/typst/<name>.typ` -- the portal can't
author a new `.typ` from scratch. Everything else in `tools/`
(voice-isolate/explode/colorize/mix, `xml2ly.sh`, the
`songs/compare-lilypond/` comparison scripts, GM-instrument overrides)
stays CLI-only for now; see `../tools/README.md`.

## How regeneration runs

Each action creates a `Job` row and runs it in a background
`threading.Thread` (see `library/jobs.py`) -- no Celery/Redis. The frontend
polls `GET /api/jobs/<id>/` while a job is pending/running and refreshes
the affected tab on success. This is fine for one person clicking one
button at a time; if this ever needs to handle concurrent multi-user load,
swap the thread for a real task queue (Celery, django-q) at that point,
not before.

`library/files.py`'s `resolve_source()` re-validates every posted
`source_path` against a fresh directory listing before `jobs.py` is allowed
to run anything with it -- a client can only ever trigger an action on a
file the portal itself just listed.

## Docker notes

- `Dockerfile` selects `typst`'s release asset by `TARGETARCH` (amd64/arm64)
  -- it'll pull the wrong-architecture binary and only work via slow
  emulation if that ever gets hardcoded to one arch again.
- Most `.typ` files set `#set text(font: "Helvetica")`, not available on
  Linux; the image renames a fetched TeX Gyre Heros (a metric-compatible,
  freely-licensed clone) to "Helvetica" so Typst's font lookup resolves it
  the same way it does on macOS, rather than silently substituting
  something else.
- The `pdf-scoryst` action needs the `@preview/scoryst` Typst package,
  fetched from Typst's registry on first compile -- the image warms that
  cache at build time (needs network during `docker compose build`) so it
  doesn't hit the registry, or fail offline, at runtime.
- The image is `python:3.14-slim` (Debian trixie) -- Debian isn't a
  deliberate choice, it's what the official Python image family is built
  on; `-slim` was picked for a smaller image and because `verovio`'s
  prebuilt wheels are `manylinux` (glibc), which Alpine's musl libc
  wouldn't satisfy without a from-source build.
- This should build and run identically on Windows (Docker Desktop runs a
  real Linux kernel there too, via WSL2 -- same as the macOS Docker
  Desktop VM, so the container never touches the host OS directly either
  way). The one Windows-specific risk isn't Docker at all: see
  `../tools/README.md`'s "Line endings on Windows" section for why
  `.gitattributes` forces LF on `*.sh`.
