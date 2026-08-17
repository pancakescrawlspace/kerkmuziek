# compare-lilypond

Scratch comparison of MusicXML→PDF engraving routes, from the exploration
that led to `songs/typst/` (see `PIPELINE.md` at the repo root for how the
three routes -- scoryst, scoryst-free Typst, LilyPond -- relate). Not part
of the canonical pipeline: nothing in this directory is read by any other
script, and everything except the scripts themselves is gitignored.

```sh
songs/compare-lilypond/generate-all.sh
```

regenerates the full set: `four-voices` and `twinkle-fugue` rendered via
LilyPond (`lilypond-compare.sh`, using LilyPond's bundled `musicxml2ly` --
a different tool than MusicFormats' `xml2ly`, see `tools/xml2ly.sh`),
MuseScore 4's CLI (`musescore-compare.sh`), and Verovio straight to PDF with
no scoryst/Typst in between (`../../tools/musicxml2pdf.sh` -- lives in
`tools/`, not here, since it's a real command-line tool in its own right,
not just a comparison artifact), plus copies of the canonical scoryst/typst
PDFs and a first-page PNG of everything for a quick look side by side.

Run the individual scripts directly to compare just one engine, or a piece
not in the default set -- see each script's header comment for usage.
