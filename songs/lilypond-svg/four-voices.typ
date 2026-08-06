// Demonstrates embedding LilyPond output into Typst as native, vector SVG --
// no extra package needed (unlike PDF, which needs something like MuchPDF).
// Typst's compilation sandbox can't invoke lilypond itself (no external
// process execution is allowed, by design), so this stays a two-stage
// pipeline: the SVG below is pre-rendered from ../lilypond/four-voices.ly
// and just imported here.
//
// It was generated with LilyPond's crop mode so the SVG is sized to its own
// content rather than a full, mostly-blank A4 page:
//
//   lilypond -e "(ly:set-option 'crop #t)" -e "(ly:set-option 'print-pages #f)" \
//     --svg -o /tmp/cropsvg four-voices.ly
//   cp /tmp/cropsvg.cropped.svg four-voices.svg
//
// Run non-destructively via -e rather than editing four-voices.ly itself, so
// the tracked .ly/.pdf/.midi (which deliberately use the full, uncropped
// page) are untouched.
//
// One tradeoff versus the PDF+MuchPDF route: LilyPond's SVG text elements
// reference "Helvetica" by name rather than embedding font outlines, so this
// only renders correctly because Typst can resolve that font locally --
// LilyPond's PDF backend, by contrast, embeds subset fonts and is fully
// self-contained.
// Normal A4 margins throughout -- any body text added later wraps at the
// usual 1in with no special indentation needed. The image is left at its
// own intrinsic width (193.36mm, per the SVG's own width= attribute) rather
// than being scaled to fill the content box -- that print width already
// matches the plain, uncropped four-voices.pdf almost exactly (verified
// with `gs -sDEVICE=bbox`: ink bounding box there is ~193.06mm wide) -- and
// a negative pad() lets just this element bleed past the margin box on both
// sides (159.2mm content width vs 193.36mm image = 34.16mm short, 17.08mm
// per side) rather than narrowing the page's own margin to fit it.
#set page(paper: "a4", margin: 1in, numbering: none)
#pad(x: -17.08mm)[#image("../lilypond/four-voices.svg")]
