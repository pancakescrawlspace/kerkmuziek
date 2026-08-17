# tools

Utilities for the scoryst song sources: compiling the Typst scores to PDF, and
turning the generated MIDI files into audio you can play (VLC, etc.).

## Dependencies

### Essential

Needed for the core score → audio pipeline (`score2mp3.sh` and friends), which
is what most of these tools are for:

- **Python 3** — every tool below is a Python script or a shell script that
  calls one.
- **[`verovio`](https://www.verovio.org/)** (`pip install verovio`) — the
  MusicXML → MIDI/SVG engine behind `choirify.py`, `score2midi.sh`,
  `score2mp3.sh`, `voice-mix.py`/`voice-mix.sh`, `musicxml2svg.py`, and
  `render-all.sh`. Not needed by `voice-isolate.py`, `voice-explode.py`, or
  `voice-colorize.py` — those three only rewrite MusicXML text and use
  nothing beyond the standard library.
- **`ffmpeg`** (built with `libmp3lame`) — the final MP3 encode in
  `score2mp3.sh`, `mid2mp3-fluidsynth.sh`, and `mid2mp3.sh`.
- **[FluidSynth](https://www.fluidsynth.org/)** + a General MIDI `.sf2`/`.sf3`
  soundfont — the portable MIDI → WAV route used by `mid2mp3-fluidsynth.sh`
  and thus `score2mp3.sh`; see [MIDI → MP3](#mid2mp3-fluidsynthsh--portable-recommended-esp-on-linux)
  below for install commands and soundfont sources. On macOS, `mid2mp3.sh`
  substitutes the system synth instead — see Non-essential.

### Non-essential

Each of these is scoped to one feature, and most have an alternative already
listed above or elsewhere in this file:

- **Typst** — only for compiling `songs/scoryst/*.typ` / `songs/typst/*.typ`
  to PDF (`compile-scores.sh`, and the `musicxml2svg.py` pipeline it depends
  on for the latter). Alternative: LilyPond, below.
- **LilyPond** (`lilypond`, plus its bundled `musicxml2ly` script) — an
  alternative MusicXML → PDF/engraving route to Typst, and needed to compile
  `xml2ly.sh`'s `.ly` output to a score.
- **[`xml2ly`](https://github.com/jacques-menu/musicformats)** — alternative
  to LilyPond's own bundled `musicxml2ly`; see
  [MusicXML → LilyPond](#musicxml--lilypond-xml2lysh).
- **`swiftc`** (Xcode command line tools) — only for `mid2mp3.sh`, the
  macOS-only alternative to FluidSynth (no soundfont needed, uses the system
  GM synth instead).
- **`mido`** (`pip install mido`) — only for `voice-mix.py`/`voice-mix.sh`
  (sets MIDI Channel Volume for the practice-mix spotlight feature).
- **`music21`** (`pip install music21`) — only for
  `voice-explode-music21.py`, an alternative to the stdlib-only
  `voice-explode.py`.

## Line endings on Windows

Every script here (`tools/*.sh`, `songs/compare-lilypond/*.sh`) is a POSIX
shell script: `#!/bin/sh` on the first line, LF-only line endings. That
first line is not decorative — it's how the OS knows what interpreter to
run the file with. If the file's line endings get changed to CRLF, that
shebang line becomes `#!/bin/sh\r`, an interpreter path that doesn't exist,
and every attempt to run the script fails with something like:

```
bash: tools/score2mp3.sh: /bin/sh^M: bad interpreter: No such file or directory
```

This is not a hypothetical: it is exactly what a default Windows Git
checkout does, unprompted. Git for Windows commonly installs with
`core.autocrlf=true`, which -- unless a repo overrides it -- rewrites every
text file's line endings to CRLF *on checkout*, because that's the native
convention for plain-text files on Windows (Notepad, `.bat` files, etc.).
Git can't tell "this LF is meaningful" from "this LF is just how someone's
editor happened to save it" on its own; `core.autocrlf` is a blanket,
repo-unaware setting, and it does exactly what it says for every text file
it sees, executable shell scripts included.

`.gitattributes`' `*.sh text eol=lf` line overrides that on a per-repo,
per-pattern basis: it tells Git "these files are text (so still get normal
diffing), but always check them out with LF, on every platform, regardless
of `core.autocrlf`." This isn't specific to Docker or WSL -- it matters for
running these scripts directly from Git Bash on Windows too, anywhere a
POSIX shell is what actually executes the `#!/bin/sh` file. It's also why
this is the right permanent fix rather than a one-time `dos2unix` pass: a
one-time conversion only fixes files already checked out; `core.autocrlf`
would just re-introduce CRLF on the *next* checkout (a fresh clone, a
branch switch, `git stash pop`, and so on) without an `.gitattributes` rule
in place to override it going forward.

Committed `.sh` files in this repo already use LF (verified via `file`
reporting plain "ASCII text", not "... with CRLF line terminators"), so
this rule is preventive -- it doesn't rewrite anything that exists today,
it just keeps a Windows checkout from silently breaking it later.

## Compile the Typst scores → PDF

The scores in `songs/scoryst/*.typ` read their notes from
`songs/musicxml/*.musicxml` — a *sibling* directory, outside each `.typ`'s own
folder. Typst sandboxes file reads to the project root, so a bare
`typst compile songs/scoryst/foo.typ` (whose default root is that file's folder)
rejects the `../musicxml/` read. Point `--root` at the repo root instead:

```sh
typst compile --root . songs/scoryst/twinkle-fugue.typ
```

`compile-scores.sh` does this for you — every score, or just the ones you name —
writing each PDF next to its `.typ`:

```sh
tools/compile-scores.sh                          # all songs/scoryst/*.typ
tools/compile-scores.sh songs/scoryst/four-voices.typ   # just this one
```

## MusicXML → LilyPond (`xml2ly.sh`)

`xml2ly.sh` converts a `.musicxml` score to a `.ly` file via
[`xml2ly`](https://github.com/jacques-menu/musicformats), the
musicxml2lilypond converter from the MusicFormats project. It's a different
implementation than the `musicxml2ly` script bundled with LilyPond itself,
with its own option set and coverage of MusicXML's feature surface.

```sh
tools/xml2ly.sh songs/musicxml/four-voices.musicxml /tmp/four-voices.ly
lilypond -o /tmp /tmp/four-voices.ly
```

`xml2ly` is not vendored in this repo — it's a single-platform ~25MB binary,
which doesn't fit how this project treats external engraving tools (`typst`,
`lilypond`, `fluidsynth`, MuseScore are all expected to be installed by the
user, not checked in). Install it yourself and put it on `PATH`; see
`xml2ly.sh`'s header comment for the download/extract steps.

## Score → MP3 in one step (recommended)

`score2mp3.sh` renders a MusicXML score straight to MP3, optionally choosing the
instrument -- the simplest entry point, and portable (Linux/macOS/WSL):

```sh
tools/score2mp3.sh songs/musicxml/twinkle-fugue.musicxml            # piano
tools/score2mp3.sh -p 53 songs/musicxml/four-voices.musicxml out.mp3  # Choir Aahs
```

It chains MusicXML → MIDI (Verovio, via `choirify.py` when `-p` is given) →
WAV (FluidSynth) → MP3 (ffmpeg). `-p N` is a 1-based General MIDI program
(53 Choir Aahs, 54 Voice Oohs, 55 Synth Voice, …); omit it to keep the score's
own instrument (piano by default). Pick the soundfont with `SOUNDFONT=…`.

Requirements: `python3` with the `verovio` package (`pip install verovio`),
`fluidsynth` + a `.sf2` soundfont, and `ffmpeg` with `libmp3lame`. On Debian/
Ubuntu: `sudo apt install fluidsynth fluid-soundfont-gm ffmpeg && pip install verovio`.

To rebuild **everything** at once, `render-all.sh` regenerates the canonical
MP3s -- a piano render of every piece plus a choir render of the choral ones
(`four-voices`, `twinkle-fugue`) -- from the scores:

```sh
tools/render-all.sh          # SOUNDFONT for piano, SOUNDFONT_CHOIR for choir
```

The committed set was built with the **GeneralUser GS** soundfont for the piano
renders and **MuseScore General** (`SOUNDFONT_CHOIR`) for the `*.choir.mp3`
renders. FluidSynth is deterministic, so re-running with the same soundfonts
reproduces them byte-for-byte; a different soundfont yields slightly different
audio. (The `*.choir-chorium.mp3` comparison renders are exploration artifacts
and are not regenerated by `render-all.sh`.)

Getting those two soundfonts — put them in `~/soundfonts` and `render-all.sh`
picks them up automatically (no env needed), reproducing the committed MP3s
exactly:

| Role | File | Source |
|---|---|---|
| piano (`SOUNDFONT`) | `GeneralUser-GS.sf2` | <https://github.com/mrbumpy409/GeneralUser-GS> (`GeneralUser-GS.sf2` at the repo root) |
| choir (`SOUNDFONT_CHOIR`) | `MuseScore_General.sf3` | <https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/> |

```sh
mkdir -p ~/soundfonts
curl -L -o ~/soundfonts/GeneralUser-GS.sf2 \
  https://raw.githubusercontent.com/mrbumpy409/GeneralUser-GS/main/GeneralUser-GS.sf2
curl -L -o ~/soundfonts/MuseScore_General.sf3 \
  https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/MuseScore_General.sf3
```

`SOUNDFONT` / `SOUNDFONT_CHOIR` in the environment still override these defaults.

The lower-level pieces below are still available if you already have a `.mid`.

## Score → MIDI

`score2midi.sh` exports a MusicXML score to a Standard MIDI File — this is how
the committed `songs/audio/*.mid` were made (Verovio's `renderToMIDI`, the
same conversion `score2mp3.sh` runs before FluidSynth). It's deterministic, so
it reproduces those `.mid` byte-for-byte.

```sh
tools/score2midi.sh songs/musicxml/twinkle-fugue.musicxml            # -> songs/musicxml/twinkle-fugue.mid
tools/score2midi.sh songs/musicxml/twinkle-fugue.musicxml songs/audio/twinkle-fugue.mid
tools/score2midi.sh -p 53 songs/musicxml/four-voices.musicxml out.mid  # Choir Aahs
```

Output defaults to `<score>.mid`; pass an explicit path to write it elsewhere
(e.g. alongside the other audio in `songs/audio/`). `-p N` picks a 1-based
General MIDI program via `choirify.py` (omit to keep the score's own
instrument). Requires only `python3` with the `verovio` package.

## MIDI → MP3

Two routes render a `.mid` to an `.mp3`. Both need `ffmpeg` (built with
`libmp3lame`) for the final encode; they differ in the synthesizer. Both
encode with `ffmpeg -codec:a libmp3lame -q:a 2` -- LAME's VBR quality scale
(0 best/~245 kbps, 9 worst/~65 kbps), so `-q:a 2` targets roughly 190 kbps.
An earlier `-q:a 5` (~130 kbps target) was landing as low as 65-115 kbps in
practice -- MIDI/soundfont renders have low transient complexity, so LAME's
VBR allocated fewer bits than the nominal target -- and sounded audibly
compressed on sustained choir/pad content; `-q:a 2` fixed it.

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
tools/mid2mp3-fluidsynth.sh songs/audio/twinkle-fugue.mid
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
tools/mid2mp3.sh songs/audio/twinkle-fugue.mid           # -> twinkle-fugue.mp3
tools/mid2mp3.sh in.mid out.mp3 3                           # 3s reverb/release tail
```

`midirender.swift` is the underlying offline MIDI → WAV renderer; the script
compiles it on first use (caching the binary in `$TMPDIR`) and encodes the MP3.

## Choir (or another GM instrument)

The renders default to piano (General MIDI program 1). To render a piece with a
different instrument -- e.g. a **choir** -- select it in the music, then render:

```sh
python3 tools/choirify.py songs/musicxml/four-voices.musicxml /tmp/fv.mid 53
SOUNDFONT=/path/to/soundfont.sf2 tools/mid2mp3-fluidsynth.sh /tmp/fv.mid four-voices.choir.mp3
```

`choirify.py` injects `<midi-program>N</midi-program>` into each part of a copy
of the MusicXML (the file on disk is untouched) and exports the MIDI via Verovio.
Useful General MIDI voices: **53 Choir Aahs**, **54 Voice Oohs**, **55 Synth
Voice**.

The committed `songs/audio/*.choir.mp3` files were made exactly this way -- GM
program 53 (Choir Aahs) -- rendered with the **MuseScore General** soundfont
(<https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/>), chosen for
its choir after comparing several. Any GM soundfont works; the choir timbre
differs from one soundfont to the next.

A `*.choir-chorium.mp3` alternative is kept for reference, rendered from the same
music with the **Chorium** soundfont (openwrld, 2003; warmer, fuller vox pads --
<https://www.pistonsoft.com/soundfonts.html>). A GeneralUser GS version was also
compared (see git history). Only the soundfont changes across them -- a
demonstration that the instrument choice lives in the music, not the soundfont.

`four-voices.choir-arachno.mp3` is a further comparison with the **Arachno
SoundFont** (Maxime Abbey, 2000-2026, GM/GS-compatible, free for personal use --
<https://www.arachnosoft.com/main/soundfont.php>), made the same way. GM
programs 54 (Voice Oohs) and 55 (Synth Voice) were also tried on this
soundfont; 53 (Choir Aahs) is the one committed:

```sh
SOUNDFONT=~/soundfonts/Arachno-SoundFont-1.0.sf2 tools/score2mp3.sh -p 53 \
  songs/musicxml/four-voices.musicxml songs/audio/four-voices.choir-arachno.mp3
```

### Real singing voice synthesis (investigated, not used)

Everything above -- "choir", "Voice Oohs", etc. -- is General MIDI sample
playback: a soundfont's *pad sound* triggered at the right pitches, not the
lyrics actually being sung. Real **singing voice synthesis (SVS)** -- a
system that takes a score plus lyrics and produces genuinely sung words --
was investigated as a further-out alternative and rejected for now, in favor
of just improving the soundfont (see above). Notes for next time:

- **[Sinsy](http://www.sinsy.jp/)** (Nagoya Institute of Technology) accepts
  **MusicXML with lyrics directly** -- the closest match to what this repo
  already produces -- but it's a web form only (no API/CLI), and the current
  UI reads Japanese-only. Not automatable as-is.
- **[OpenUtau](https://github.com/openutau/OpenUtau)** (+ classic UTAU
  voicebanks, or its ENUNU mode for AI-driven ones) is free, actively
  maintained, and has real English phonemizers/voicebanks, but is GUI-first
  with no confirmed headless/CLI render, and no direct MusicXML import (would
  need a MusicXML → `.ustx` converter, or manual MIDI+lyrics import).
- **[NNSVS](https://github.com/nnsvs/nnsvs)** / **DiffSinger** are the neural
  engines behind OpenUtau's ENUNU mode and reportedly the best-quality option
  (one study had NNSVS beating both Sinsy and DiffSinger on MOS), but they're
  research toolkits: a trained voice model/corpus is generally required, a
  GPU is preferred, and setup is well beyond `pip install`.

Bottom line: getting real sung words is a different technology stack, not a
parameter tweak -- real setup cost (voice model acquisition, format
conversion, possibly a GUI-centric workflow), no fully turnkey free English
CLI-scriptable option today. If pursued, OpenUtau + a community English
voicebank is the most realistic starting point.

## Isolate a single voice

`voice-isolate.py` mutes every voice except the one you name, turning its
notes into same-duration rests -- render the result and you hear only that
line, useful for rehearsal tracks:

```sh
python3 tools/voice-isolate.py songs/musicxml/four-voices.musicxml /tmp/soprano.musicxml soprano
tools/score2mp3.sh /tmp/soprano.musicxml soprano.mp3
```

The voice can be a `<part-name>` label from the score (`Soprano`, `Alto`,
`Tenor`, `Bass` for `four-voices.musicxml`, matched case-insensitively) or an
explicit `<part-id>:<voice-number>` like `P1:1`. As with `choirify.py`, it
rewrites a copy of the MusicXML -- the file on disk is untouched -- and needs
only the standard library (no `verovio` required for this step).

## Emphasize one voice (practice mix)

To study one voice while still hearing the others in the background -- rather
than muting them entirely, as `voice-isolate.py` does -- split the score's
multi-voice parts into one part per voice with `voice-explode.py`:

```sh
python3 tools/voice-explode.py songs/musicxml/four-voices.musicxml /tmp/four-voices.exploded.musicxml
```

A part like `<part-name>Soprano/Alto</part-name>` carrying `<voice>1</voice>`
and `<voice>2</voice>` notes on one staff becomes two full parts (`Soprano`,
`Alto`), nothing muted or dropped -- just regrouped. Single-voice parts are
left untouched. This matters because Verovio assigns each `<part>` its own
MIDI channel on export but does not split channels *within* a part by voice,
so an independent volume per voice requires a per-voice part first.

Choral scores conventionally print the lyrics only once (usually under the
top voice), since every voice sings the same syllable at the same moment --
once split onto separate staves that's no longer implicit, so `voice-explode.py`
has any note being exploded that has no lyric of its own borrow one from
whichever voice/part in the score *does* have lyrics at that position (matched
by measure + beat offset, not just note index, so it still lines up if a
voice's rhythm differs). A note that already carries its own lyric is left
alone. `voice-explode-single-lyrics.py` is the same script without this step,
for when you want the words to stay exactly where the source put them
(standard engraving practice, or a score you plan to typeset for print rather
than per-voice study) -- otherwise identical, same CLI, drop-in replacement.

The exploded file is a real, standalone MusicXML score on its own (e.g. one
staff per voice instead of two), but its purpose here is as input to
`voice-mix.sh`, which assigns each part a MIDI channel, sets a louder volume
on the voice you're studying and quieter volumes on the rest via MIDI Control
Change #7 (Channel Volume -- confirmed to give roughly a 32 dB spread between
CC7 values of 20 and 127 with this project's FluidSynth rendering), then
renders through the existing MIDI → WAV → MP3 pipeline:

```sh
tools/voice-mix.sh /tmp/four-voices.exploded.musicxml soprano-mix.mp3 soprano
tools/voice-mix.sh /tmp/four-voices.exploded.musicxml soprano-mix.mp3 soprano 127 60   # subtler background
tools/voice-mix.sh -p 53 /tmp/four-voices.exploded.musicxml soprano-mix.mp3 soprano    # Choir Aahs instead of piano
```

`<spotlight-voice>` is a `<part-name>` label (matched case-insensitively, as
in `voice-isolate.py`) or an explicit `<part-id>`; the two trailing numbers
are the spotlight and background MIDI Channel Volumes (0-127, default 127/40).
If the voice you want shares a part with another (as in the original,
un-exploded `four-voices.musicxml`), `voice-mix.sh` still works but only at
part granularity -- run `voice-explode.py` first for independent control of
every voice.

`-p` sets the GM instrument for every part, but the spotlighted part can also
carry a *different* instrument than the background via `-P` -- e.g. the voice
you're studying stays a choir "ah" while the other three drop to piano, a
starker foreground/background split than volume alone:

```sh
tools/voice-mix.sh -p 1 -P 53 /tmp/four-voices.exploded.musicxml soprano-vocal-piano-bg.mp3 soprano
```

`-P` defaults to whatever `-p` is (one uniform instrument, the original
behaviour) when omitted.

Under the hood, `voice-mix.py` does the MusicXML → MIDI + Channel Volume step
alone (useful standalone if you just want the `.mid`); `voice-mix.sh` adds the
FluidSynth/ffmpeg render, reusing `mid2mp3-fluidsynth.sh`. Needs the `mido`
package in addition to `verovio` (`pip install verovio mido`).

The committed `songs/audio/four-voices.choir.{soprano,alto,tenor,bass}.mp3` --
one per voice, spotlighted in turn -- were made from the already-exploded
`songs/musicxml/four-voices.exploded.musicxml`, GM program 53 (Choir Aahs),
with the same **MuseScore General** soundfont as `four-voices.choir.mp3`.
Background volume is raised to 75 (from the 40 default) -- at equal Channel
Volume this soundfont's patches aren't inherently quieter or louder than one
another (confirmed by soloing background vs. spotlight at the same CC7 value
and comparing loudness), so the intended spotlight/background split was
entirely down to the CC7 gap, and the default 40 read as too soft:

```sh
for voice in soprano alto tenor bass; do
  SOUNDFONT=~/soundfonts/MuseScore_General.sf3 tools/voice-mix.sh -p 53 \
    songs/musicxml/four-voices.exploded.musicxml \
    "songs/audio/four-voices.choir.$voice.mp3" "$voice" 127 75
done
```

`songs/audio/four-voices.vocal-piano.{soprano,alto,tenor,bass}.mp3` are the
`-p`/`-P` split-instrument version of the same set: the spotlighted voice
stays Choir Aahs, the other three drop to piano, same soundfont and same
127/75 balance:

```sh
for voice in soprano alto tenor bass; do
  SOUNDFONT=~/soundfonts/MuseScore_General.sf3 tools/voice-mix.sh -p 1 -P 53 \
    songs/musicxml/four-voices.exploded.musicxml \
    "songs/audio/four-voices.vocal-piano.$voice.mp3" "$voice" 127 75
done
```

`songs/audio/four-voices.vocal-piano-arachno.{soprano,alto,tenor,bass}.mp3`
is the same vocal/piano split again, but with the **Arachno SoundFont**
(see above) instead of MuseScore General:

```sh
for voice in soprano alto tenor bass; do
  SOUNDFONT=~/soundfonts/Arachno-SoundFont-1.0.sf2 tools/voice-mix.sh -p 1 -P 53 \
    songs/musicxml/four-voices.exploded.musicxml \
    "songs/audio/four-voices.vocal-piano-arachno.$voice.mp3" "$voice" 127 75
done
```

### Two ways to explode: regex vs. music21

`voice-explode.py` is hand-written regex/XML surgery, scoped to exactly what
this project's scores use (no chords, no `<forward>`, single-staff parts).
`voice-explode-music21.py` does the same job -- same CLI, same output
semantics, same part-naming convention -- via
[music21](https://www.music21.org/music21docs/)'s `Score.voicesToParts()`
instead:

```sh
python3 tools/voice-explode-music21.py songs/musicxml/four-voices.musicxml /tmp/four-voices.exploded-m21.musicxml
```

Both were verified to produce the same notes/rhythms on `four-voices.musicxml`
(62 notes per voice, 4 parts, correct Soprano/Alto/Tenor/Bass names) and both
feed `voice-mix.sh` identically -- it resolves parts by name, so it doesn't
care which route produced the file. The real differences:

|  | `voice-explode.py` (regex) | `voice-explode-music21.py` |
|---|---|---|
| Dependency | standard library only | `music21` (`pip install music21`) -- a full notation/analysis library |
| Scope | handles this project's scores; would need extending for chords, `<forward>`, multi-staff parts | music21's object model already handles those cases generally |
| Untouched parts | already-single-voice parts pass through **byte-identical** | every part gets rewritten, even ones that didn't need splitting |
| Lyrics | notes with no lyric of their own borrow one from another voice/part at the same position (see above) | not implemented -- only the voice that already had lyrics in the source keeps them |
| Output size/style | matches the source file's formatting | ~45% larger, reformatted (multi-line elements, `<divisions>` inflated to music21's internal PPQ, e.g. 1 → 10080) |
| Part ids | `<original-id>-<voice>`, e.g. `P1-1` | opaque hashes for every part but the first per original id (`Part.id` is set but silently ignored on write -- only `partName` survives) |

For this repo's scores, `voice-explode.py` is the one actually wired into the
practice-mix workflow above (no extra dependency, output that reads like the
rest of `songs/musicxml/`); `voice-explode-music21.py` exists to compare
against and as a fallback if a future score uses a MusicXML feature the regex
version doesn't handle.

## Emphasize one voice, visually (colored score)

The visual counterpart to `voice-mix.sh`: `voice-colorize.py` colors one
voice's notes in a MusicXML score instead of muting or spotlighting them in
audio. It works by setting MusicXML's standard `color` attribute on the
target `<note>` elements -- Verovio (the engine behind `score2mp3.sh` and the
`scoryst` Typst package used for `songs/scoryst/*.typ`) renders that note's
whole glyph -- notehead, stem, ledger lines, and its lyric syllable -- in the
given color; everything else stays black. Nothing else about the notation
changes.

```sh
python3 tools/voice-colorize.py songs/musicxml/four-voices.exploded.musicxml /tmp/soprano-red.musicxml soprano
python3 tools/voice-colorize.py songs/musicxml/four-voices.exploded.musicxml /tmp/alto-blue.musicxml alto "#2255CC"
python3 tools/voice-colorize.py songs/musicxml/four-voices.exploded.musicxml /tmp/soprano-red.musicxml soprano --notes-only
```

`--notes-only` keeps the lyrics black regardless of voice: Verovio nests a
note's lyric syllable inside that note's SVG group, so it inherits the note's
color by default (colored words included) unless overridden -- the flag adds
an explicit `color="#000000"` on each `<lyric>` the colored note carries.

`<voice>` is a `<part-name>` label or an explicit `<part-id>[:<voice-number>]`,
same matching convention as `voice-isolate.py`/`voice-mix.sh`. It works on
either an exploded score (from `voice-explode.py`, one voice per part -- name
the part directly, e.g. `soprano`) or the original un-exploded score (name a
"/"-separated sub-label, e.g. `tenor` within `<part-name>Tenor/Bass</part-name>`,
which colors just that voice's notes by their `<voice>` tag).

To see the result, point any `songs/scoryst/*.typ` file's `score(read(...))`
call at the colorized file instead of the original -- e.g. copy
`four-voices-exploded.typ` and change its `read(...)` path -- then
`typst compile --root . songs/scoryst/your-copy.typ`.

## Notes

- Both default to the General MIDI **piano** (program 0), which suits the
  current pieces. FluidSynth makes it easy to use a richer soundfont.
- `*.mp3` is tracked with Git LFS (see `.gitattributes`), matching the
  pdf/png/svg convention.
