// svg-score.typ -- a small svg-pages()/svg-score() pair that plays the same
// role as the scoryst package's pages()/score(), but for SVGs already
// rendered to disk by tools/musicxml2svg.py, instead of calling Verovio
// itself (scoryst bundles Verovio compiled to WASM; this reads plain files).
//
// Used by songs/typst/*.typ (the scoryst-free counterparts of
// songs/scoryst/*.typ -- that directory and its scoryst dependency are
// untouched). Typical use:
//
//   #import "svg-score.typ": svg-score, svg-pages
//   #let prefix = "/songs/musicxml-svg/four-voices"
//   #for p in range(1, svg-pages(prefix) + 1) [
//     #if p > 1 [ #pagebreak() ]
//     #svg-score(prefix, page: p, width: 100%)
//   ]
//
// songs/musicxml-svg/ is where the SVGs musicxml2svg.py writes actually live.
//
// IMPORTANT -- compile with --font-path songs/typst/fonts (see
// tools/musicxml2svg.py's docstring for why): Verovio's SVG text elements
// -- a tempo mark's note symbol, for instance -- reference the Leipzig
// engraving font by name, and Typst's image() only resolves that against a
// real, discoverable font file, not the @font-face/data-URI declaration
// already embedded in the SVG. Without --font-path, such glyphs silently
// render as a missing-glyph box instead of failing loudly, so it's easy to
// miss:
//
//   typst compile --root . --font-path songs/typst/fonts songs/typst/four-voices.typ
//
// `prefix` is whatever path was passed to musicxml2svg.py as its
// <output-prefix> argument -- this expects `prefix-N.svg` and
// `prefix.pages` (a plain integer) next to each other, exactly what that
// script writes. IMPORTANT: pass `prefix` as an absolute, --root-relative
// path (leading `/`, resolved against `typst compile --root .`), not a
// relative one -- Typst resolves read()/image() paths against the file
// where the call is *written* (here, i.e. always this file's directory),
// not the file that calls svg-pages()/svg-score(), so a relative prefix
// would be resolved from songs/typst/ regardless of where you call this
// from.

/// Number of pages musicxml2svg.py rendered for this prefix.
#let svg-pages(prefix) = int(read(prefix + ".pages"))

/// Render one page's SVG as an image (`..args` forwarded to `image()`,
/// e.g. `width: 100%`).
#let svg-score(prefix, page: 1, ..args) = {
  image(prefix + "-" + str(page) + ".svg", ..args.named())
}
