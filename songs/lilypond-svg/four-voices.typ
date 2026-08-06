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
// Page sized to the image's own content rather than a fixed A4 sheet: a
// fixed page left a lot of blank space below the (comparatively short)
// score, and constraining the image to a fixed page's content width was
// also scaling it down from the size LilyPond's own crop already gave it.
// width/height: auto lets the page shrink to exactly fit the image plus
// this margin instead.
#set page(width: auto, height: auto, margin: 1cm, numbering: none)
#image("../lilypond/four-voices.svg")
