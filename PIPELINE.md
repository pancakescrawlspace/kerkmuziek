# Tools → songs/ pipeline

How the scripts in `tools/` turn the MusicXML sources in `songs/musicxml/`
into notation PDFs (`songs/scoryst/`, `songs/typst/`) and the MIDI/MP3 files
in `songs/audio/`. See `tools/README.md` for full CLI usage of every tool
mentioned here.

Legend: cylinders are file groups (an artifact directory or glob), rectangles
are scripts/programs, solid arrows are "produces/reads", dotted arrows are
"internally calls" (not a separate data-flow step).

## 1. MusicXML → MusicXML (voice-level preprocessing)

Optional preprocessing tools that read a score and write a *derived*
MusicXML file -- used to prepare per-voice practice material before it goes
into either the notation or audio pipeline below.

```mermaid
flowchart LR
    MXML[("*.musicxml<br/>source score")]
    VI["voice-isolate.py<br/>mute all but one voice"]
    VE["voice-explode.py<br/>(or -single-lyrics /<br/>-music21 variants)"]
    VC["voice-colorize.py<br/>color one voice's notes"]

    MXML --> VI --> ISO(("single-voice .musicxml<br/>ad hoc, not committed"))
    MXML --> VE --> EXP[("*.exploded.musicxml<br/>one voice per part")]
    EXP --> VC --> COL[("*.exploded.VOICE.musicxml<br/>one voice colored")]
```

`voice-explode.py` splits a part carrying multiple `<voice>`s on one staff
(e.g. Soprano/Alto sharing a treble stave) into one part per voice --
required before `voice-mix.py`/`voice-mix.sh` (below) can give each voice
its own MIDI channel. `voice-colorize.py` then highlights one of those parts
in red for visual study; `voice-isolate.py` instead mutes every voice but
one, for a quick rehearsal-track listen via the audio pipeline.

## 2. Notation: MusicXML → PDF

Three routes from the same MusicXML sources, kept side by side rather than
one replacing another -- see `tools/README.md`'s Dependencies section for
what each needs, and why some are essential and some aren't.

```mermaid
flowchart LR
    MXML[("songs/musicxml/*.musicxml<br/>incl. exploded / colored")]

    subgraph scoryst ["scoryst"]
        TYP[("songs/scoryst/*.typ<br/>scoryst package")]
        CS["compile-scores.sh<br/>typst compile --root ."]
    end
    MXML --> TYP --> CS --> PDF1[("songs/scoryst/*.pdf")]

    subgraph typst_direct ["scoryst-free Typst"]
        SVG2["musicxml2svg.py<br/>verovio Python bindings"]
        SVGS[("songs/musicxml-svg/*.svg")]
        TYP2[("songs/typst/*.typ<br/>svg-score.typ helper")]
    end
    MXML --> SVG2 --> SVGS --> TYP2 -- "typst compile<br/>--font-path songs/typst/fonts" --> PDF2[("songs/typst/*.pdf")]

    subgraph lilypond ["LilyPond"]
        X2LY["xml2ly.sh<br/>MusicFormats xml2ly"]
        LY[(".ly")]
    end
    MXML --> X2LY --> LY -- "lilypond" --> PDF3[("*.pdf<br/>ad hoc, not committed")]
```

- **scoryst** -- the original route. Each `.typ` file `read()`s a MusicXML
  sibling and renders it via the `scoryst` Typst package (a Verovio-to-SVG
  wrapper bundled as WASM); `compile-scores.sh` drives `typst compile` over
  some or all of `songs/scoryst/*.typ`.
- **scoryst-free Typst** -- the same idea without the `scoryst` package
  in between. `musicxml2svg.py` calls Verovio's Python bindings directly
  and writes one SVG per page to `songs/musicxml-svg/` (plus a `.pages`
  count), looping over every page itself -- fixing a `scoryst` bug where a
  score tall enough to need more than one page silently lost everything past
  page 1. `songs/typst/svg-score.typ`'s `svg-pages()`/`svg-score()` read
  those files back in, as a drop-in-ish replacement for `scoryst`'s
  `pages()`/`score()`, from `songs/typst/*.typ`. Compiling needs
  `--font-path songs/typst/fonts` -- Typst's SVG embedding doesn't honour
  the font `@font-face`/data-URI declarations Verovio's SVG already embeds
  for text-based glyphs (e.g. a tempo mark's note symbol), only real,
  discoverable font files. Known cosmetic gap: tempo marks render visibly
  bolder here than in scoryst, reading as if they sit closer to the staff --
  investigated and it's a Typst SVG font-matching quirk, not an actual
  spacing difference; see `musicxml2svg.py`'s docstring for the full
  writeup.
- **LilyPond** -- a non-Typst route. `xml2ly.sh` wraps the MusicFormats
  project's `xml2ly` to convert a MusicXML file to a `.ly`, which `lilypond`
  then engraves to PDF directly (`tools/README.md` has the two-command
  usage). Not wired into a `songs/` directory of its own yet -- output goes
  wherever you point it.

## 3. Audio: MusicXML/MIDI → MP3

```mermaid
flowchart TD
    MXML[("songs/musicxml/*.musicxml")]
    MXML_EXP[("*.exploded.musicxml<br/>one voice per part")]

    CHOIRIFY["choirify.py<br/>inject GM instrument"]
    S2MID["score2midi.sh"]
    S2MP3["score2mp3.sh<br/>recommended, one step"]
    VMIXPY["voice-mix.py<br/>per-part channel/volume/instrument"]

    MXML --> CHOIRIFY
    MXML --> S2MID
    MXML --> S2MP3
    MXML_EXP --> VMIXPY
    S2MID -. uses .-> CHOIRIFY
    S2MP3 -. uses .-> CHOIRIFY

    MID[("songs/audio/*.mid")]
    CHOIRIFY --> MID
    S2MID --> MID
    VMIXPY --> MID

    MID2MP3F["mid2mp3-fluidsynth.sh<br/>FluidSynth, portable"]
    MID2MP3M["mid2mp3.sh<br/>macOS DLSMusicDevice"]
    MIDIRENDER["midirender.swift"]
    VMIXSH["voice-mix.sh<br/>spotlight one voice"]
    RENDERALL["render-all.sh<br/>rebuild the canonical set"]

    MID --> MID2MP3F
    MID --> MID2MP3M
    MID2MP3M -. uses .-> MIDIRENDER
    S2MP3 -. uses .-> MID2MP3F
    VMIXSH -. uses .-> VMIXPY
    VMIXSH -. uses .-> MID2MP3F
    MXML_EXP --> VMIXSH
    RENDERALL -. runs .-> S2MP3

    MP3[("songs/audio/*.mp3")]
    MID2MP3F --> MP3
    MID2MP3M --> MP3
```

`choirify.py` injects a `<midi-instrument>` into a copy of the score (GM
program 1/piano by default); `score2midi.sh`/`score2mp3.sh` call it
internally only when `-p` is given, otherwise the instrument comes from
Verovio's own default. `voice-mix.py` does the same channel-assignment job
but per-part, so a spotlighted voice can get its own volume and instrument
independent of the rest -- `voice-mix.sh` wraps it with the FluidSynth
render, and needs `four-voices.exploded.musicxml`-style input (§1) to have
one voice per part. `render-all.sh` just batches `score2mp3.sh` over every
piece (piano) and the choral pieces (choir), and does not touch the
per-voice spotlight tools.

## Out of scope

`songs/lilypond/`, `songs/lilypond-svg/`, and `songs/typed-scores/` hold
earlier, hand-run experiments (LilyPond engraving, then LilyPond-SVG-in-Typst)
that predate the `scoryst`-based pipeline above. No script in `tools/`
reads or writes them.
