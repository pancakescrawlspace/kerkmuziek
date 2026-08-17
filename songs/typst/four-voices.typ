#import "../../tools/typst/svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)

// scoryst-free counterpart of songs/scoryst/four-voices.typ: same score,
// but the SVG comes from tools/musicxml2svg.py (plain verovio Python
// bindings) instead of the scoryst package. See tools/typst/svg-score.typ.
#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, simple demo harmonization])
#v(12pt)

#let prefix = "/songs/musicxml-svg/four-voices"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]
