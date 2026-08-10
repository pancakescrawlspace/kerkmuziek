# tools

Utilities for the scoryst song sources. Currently: turning the generated MIDI
files into audio you can play (VLC, etc.).

## Score → MP3 in one step (recommended)

`score2mp3.sh` renders a MusicXML score straight to MP3, optionally choosing the
instrument -- the simplest entry point, and portable (Linux/macOS/WSL):

```sh
tools/score2mp3.sh songs/scoryst/twinkle-fugue.musicxml            # piano
tools/score2mp3.sh -p 53 songs/scoryst/four-voices.musicxml out.mp3  # Choir Aahs
```

It chains MusicXML → MIDI (Verovio, via `choirify.py` when `-p` is given) →
WAV (FluidSynth) → MP3 (ffmpeg). `-p N` is a 1-based General MIDI program
(53 Choir Aahs, 54 Voice Oohs, 55 Synth Voice, …); omit it to keep the score's
own instrument (piano by default). Pick the soundfont with `SOUNDFONT=…`.

Requirements: `python3` with the `verovio` package (`pip install verovio`),
`fluidsynth` + a `.sf2` soundfont, and `ffmpeg` with `libmp3lame`. On Debian/
Ubuntu: `sudo apt install fluidsynth fluid-soundfont-gm ffmpeg && pip install verovio`.

The lower-level pieces below are still available if you already have a `.mid`.

## MIDI → MP3

Two routes render a `.mid` to an `.mp3`. Both need `ffmpeg` (built with
`libmp3lame`) for the final encode; they differ in the synthesizer.

### `mid2mp3-fluidsynth.sh` — portable (recommended, esp. on Linux)

Uses [FluidSynth](https://www.fluidsynth.org/) with a General MIDI `.sf2`
soundfont. Runs on Linux, macOS, and Windows/WSL, and lets you swap soundfonts
for different instrument sounds.

Install (FluidSynth + a GM soundfont + ffmpeg):

| Platform | Command |
|---|---|
| Debian/Ubuntu | `sudo apt install fluidsynth fluid-soundfont-gm ffmpeg` |
| Fedora | `sudo dnf install fluidsynth fluid-soundfont-gm ffmpeg` |
| Arch | `sudo pacman -S fluidsynth soundfont-fluid ffmpeg` |
| macOS (Homebrew) | `brew install fluid-synth ffmpeg` (then fetch a `.sf2`) |
| macOS (MacPorts) | `sudo port install fluidsynth ffmpeg` (then fetch a `.sf2`) |

Usage:

```sh
tools/mid2mp3-fluidsynth.sh songs/scoryst/twinkle-fugue.mid
# override the soundfont if autodetection misses it:
SOUNDFONT=~/soundfonts/FluidR3_GM.sf2 tools/mid2mp3-fluidsynth.sh foo.mid out.mp3
```

The Linux `fluid-soundfont-gm` package installs `FluidR3_GM.sf2` under
`/usr/share/sounds/sf2/`, which the script autodetects. On macOS you generally
download a `.sf2` yourself and point `SOUNDFONT` at it.

### `mid2mp3.sh` — macOS-only, no third-party synth

Uses macOS's built-in General MIDI synth (the system `DLSMusicDevice` audio unit
+ Apple's GM soundfont) via `midirender.swift`, so it needs **no** FluidSynth or
soundfont — only the Xcode command line tools (`swiftc`) and `ffmpeg`. Handy on a
stock Mac, but not portable.

```sh
tools/mid2mp3.sh songs/scoryst/twinkle-fugue.mid           # -> twinkle-fugue.mp3
tools/mid2mp3.sh in.mid out.mp3 3                           # 3s reverb/release tail
```

`midirender.swift` is the underlying offline MIDI → WAV renderer; the script
compiles it on first use (caching the binary in `$TMPDIR`) and encodes the MP3.

## Choir (or another GM instrument)

The renders default to piano (General MIDI program 1). To render a piece with a
different instrument -- e.g. a **choir** -- select it in the music, then render:

```sh
python3 tools/choirify.py songs/scoryst/four-voices.musicxml /tmp/fv.mid 53
SOUNDFONT=/path/to/soundfont.sf2 tools/mid2mp3-fluidsynth.sh /tmp/fv.mid four-voices.choir.mp3
```

`choirify.py` injects `<midi-program>N</midi-program>` into each part of a copy
of the MusicXML (the file on disk is untouched) and exports the MIDI via Verovio.
Useful General MIDI voices: **53 Choir Aahs**, **54 Voice Oohs**, **55 Synth
Voice**.

The committed `songs/scoryst/*.choir.mp3` files were made exactly this way -- GM
program 53 (Choir Aahs), rendered with the **GeneralUser GS** soundfont
(<https://github.com/mrbumpy409/GeneralUser-GS>). Any GM soundfont works; the
choir timbre differs from one soundfont to the next. GM "Choir Aahs" is a
sustained "aah" pad -- atmospheric, but not a lifelike chorus; a dedicated choir
soundfont gives richer results.

The `*.choir-chorium.mp3` files are the same music and program, rendered instead
with the **Chorium** soundfont (openwrld, 2003), long prized for warmer, fuller
choir/vox pads (<https://www.pistonsoft.com/soundfonts.html>). Only the `.sf2`
changed -- a demonstration that the instrument choice lives in the music, not the
soundfont.

## Notes

- Both default to the General MIDI **piano** (program 0), which suits the
  current pieces. FluidSynth makes it easy to use a richer soundfont.
- `*.mp3` is tracked with Git LFS (see `.gitattributes`), matching the
  pdf/png/svg convention.
