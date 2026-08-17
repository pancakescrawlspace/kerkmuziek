#import "svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)

// scoryst-free counterpart of songs/scoryst/twinkle-twinkle-musicxml.typ.
// (songs/scoryst/twinkle-twinkle.typ and twinkle-twinkle-stanzas.typ are
// inline-ABC, not MusicXML -- out of scope for musicxml2svg.py, so they
// have no counterpart here.)
#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#v(12pt)

#let prefix = "/songs/musicxml-svg/twinkle-twinkle-musicxml"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]
