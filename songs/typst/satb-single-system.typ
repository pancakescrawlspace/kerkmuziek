#import "svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// scoryst-free counterpart of songs/scoryst/satb-single-system.typ.
// Simplified on purpose: the original measures its own rendered width
// (twice, at different Verovio options) to compute a scale factor, then
// place()s the performance instruction at coordinates hand-measured from
// one specific render. That's a lot of indirection for what this file is
// demonstrating (a scoryst-free rendering pipeline) -- a transparent, easy
// to follow file matters more here than reproducing that exact layout, so
// this just prints the instruction as a plain caption above the score
// instead of overlaying it in place.
#align(center, text(weight: "bold", size: 16pt)[A Little SATB Phrase])
#v(12pt)

#align(center, text(style: "italic", size: 10pt)[Singers wave their hands.])
#v(8pt)

#let prefix = "/songs/musicxml-svg/satb-single-system"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]
