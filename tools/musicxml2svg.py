#!/usr/bin/env python3
"""musicxml2svg.py -- render a MusicXML score to one SVG per page via
Verovio's Python bindings directly, with no scoryst / Typst-WASM in between.

This is what the scoryst Typst package's score() call does internally
(Verovio -> SVG), minus the third-party wrapper: same `verovio` package this
project already depends on for MIDI export (choirify.py, score2midi.sh),
just also asked for SVG instead of MIDI. The point of doing this ourselves
is pagination: scoryst's score() only ever renders the page you ask for
(default page 1), so a score tall enough that Verovio's adjustPageHeight
needs more than one page silently loses everything past page 1 unless the
caller loops over pages() -- see tools/README.md's note on the bug that
caused in songs/scoryst/four-voices-exploded.typ. This script does that
looping itself and writes every page.

Only two Verovio options are applied by default -- adjustPageHeight and
inputFrom: auto -- matching exactly what scoryst itself always merges in
(see its _serialize-options). Everything else scoryst's various *.typ files
pass per-call (header, adjustPageWidth, lyricWordSpace, ...) is NOT a
universal default here either; pass it explicitly with --option so each
score's rendering matches what it asked scoryst for.

Writes <output-prefix>-1.svg, -2.svg, ... and <output-prefix>.pages (a
plain-text page count), so a Typst file can loop over exactly as many pages
as were written without probing the filesystem -- see songs/typst/svg-score.typ,
a small svg-pages()/svg-score() pair that reads what this script writes, as
a drop-in-ish replacement for scoryst's pages()/score().

Usage:
    python3 tools/musicxml2svg.py <input.musicxml> <output-prefix> [--option key=value ...]

--option accepts any Verovio toolkit option, camelCase (e.g.
--option adjustPageWidth=true --option lyricWordSpace=3.0). Values are
parsed as bool ("true"/"false"), then int, then float, else left as a
string.

Examples (songs/musicxml-svg/ is where the committed songs/typst/*.typ files'
SVGs live):
    python3 tools/musicxml2svg.py songs/musicxml/four-voices.musicxml songs/musicxml-svg/four-voices
    python3 tools/musicxml2svg.py songs/musicxml/unequal-fifths.musicxml songs/musicxml-svg/unequal-fifths --option adjustPageWidth=true
    # -> songs/musicxml-svg/four-voices-1.svg [, -2.svg, ...], songs/musicxml-svg/four-voices.pages

IMPORTANT -- font: Verovio's SVG text elements (tempo marks, and potentially
other text-based annotations) reference the engraving font -- Leipzig by
default -- by name via `font-family`. Verovio's own output DOES already
carry a matching `@font-face { ... url(data:...) }` rule, but Typst's SVG
embedding (plain image(), as songs/typst/svg-score.typ uses) does not honour
embedded @font-face/data-URI declarations -- it resolves font-family names
against real, discoverable font files only. Without the font available that
way, any Leipzig-glyph text (e.g. the note symbol in a metronome mark)
silently renders as a missing-glyph box. songs/typst/fonts/Leipzig.ttf is
that font, extracted once from the `verovio` package's bundled Leipzig.css
(see git history for the extraction commands); pass it to Typst explicitly:

    typst compile --root . --font-path songs/typst/fonts songs/typst/foo.typ

KNOWN COSMETIC ISSUE -- plain SVG text (e.g. the "= 100" half of a tempo
mark, font-family="Times, serif") renders visibly bolder/heavier here than
in the scoryst pipeline, making it look like it sits closer to the staff.
Investigated and it is NOT a spacing bug: the tempo mark's baseline sits at
the same offset above the staff in the raw SVG regardless of Verovio version
(tried 6.0.1 and 6.2.1) or option (dynamDist, harmDist, justificationStaff,
spacingStaff, pageMarginTop all tried, none move it), and MusicXML's
default-y position hint is ignored entirely by Verovio's auto-layout here
(confirmed on both the tempo mark and the already-encoded default-y="48" on
the "Parallel fifths"/"Corrected" labels in parallel-fifths-octaves.musicxml
-- no visible effect from changing that value either). The actual cause:
Typst's SVG-image font resolution does not do real name-based font-family
matching -- tried pointing --font-path at real "Times"/"Times New Roman"
files (both the literal name Verovio requests and stamped directly on the
text element, bypassing inheritance), and none of it changed the render;
removing Leipzig.ttf from --font-path turns the plain digits to tofu too,
even with a real Times font still present, which rules out name-based
lookup happening at all. It looks like whichever font gets loaded to supply
the Leipzig glyph (the one glyph that has no alternative) becomes a blanket
substitute for all other undeclared-family text in the same image,
regardless of what font-family is actually declared. No fix found via
Verovio options, font files, or MusicXML-side positioning; a real fix would
mean not routing this text through Typst's SVG font matching at all (e.g.
extracting these text runs and placing them as native Typst text on top of
the image instead of leaving them inside the embedded SVG) -- a bigger
change than a font swap, and worth doing for lyrics/dynamics too if done at
all, not just tempo marks. Left as a known cosmetic gap for now.

Requires the `verovio` Python package.
"""
import sys
import pathlib
import verovio

DEFAULT_OPTIONS = {"adjustPageHeight": True, "inputFrom": "auto"}


def parse_option_value(raw: str):
    if raw.lower() in ("true", "false"):
        return raw.lower() == "true"
    for cast in (int, float):
        try:
            return cast(raw)
        except ValueError:
            pass
    return raw


def parse_args(argv: list) -> tuple:
    options = {}
    positional = []
    i = 0
    while i < len(argv):
        if argv[i] == "--option":
            i += 1
            if i >= len(argv) or "=" not in argv[i]:
                sys.exit("--option requires a key=value argument")
            key, _, value = argv[i].partition("=")
            options[key] = parse_option_value(value)
        else:
            positional.append(argv[i])
        i += 1
    if len(positional) != 2:
        sys.exit(
            "usage: musicxml2svg.py <input.musicxml> <output-prefix> [--option key=value ...]"
        )
    return positional[0], positional[1], options


def render_pages(xml: str, extra_options: dict) -> list:
    """Return a list of SVG strings, one per Verovio page."""
    tk = verovio.toolkit()
    tk.setOptions({**DEFAULT_OPTIONS, **extra_options})
    if not tk.loadData(xml):
        sys.exit("verovio failed to load the score")
    return [tk.renderToSVG(p) for p in range(1, tk.getPageCount() + 1)]


def main() -> None:
    inp, prefix, extra_options = parse_args(sys.argv[1:])

    pages = render_pages(open(inp).read(), extra_options)
    for i, svg in enumerate(pages, start=1):
        pathlib.Path(f"{prefix}-{i}.svg").write_text(svg)
    pathlib.Path(f"{prefix}.pages").write_text(str(len(pages)))

    print(f"wrote {len(pages)} page(s): {prefix}-1.svg .. {prefix}-{len(pages)}.svg, {prefix}.pages")


if __name__ == "__main__":
    main()
