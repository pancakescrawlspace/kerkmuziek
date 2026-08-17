#import "../../tools/typst/svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// scoryst-free counterpart of songs/scoryst/parallel-fifths-octaves.typ.
#align(center, text(weight: "bold", size: 16pt)[Parallel Fifths & Octaves])
#align(center, text(size: 11pt, style: "italic")[why they are avoided in part-writing])
#v(14pt)

#let prefix = "/songs/musicxml-svg/parallel-fifths-octaves"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]

#v(18pt)

#set text(size: 10pt)
#block(width: 100%, [
  *What to listen for.* In the faulty examples both voices move in the same
  direction while holding a perfect fifth (or octave). A perfect fifth/octave
  blends so completely that the two voices stop sounding independent and merge
  into one thickened line -- the very independence that two-voice writing exists
  to create is lost. The corrected examples keep the same upper line but harmonise
  it with thirds and sixths (imperfect consonances) and some contrary motion, so
  the two voices stay audibly distinct. Play *parallel-fifths-octaves.mid* to
  hear the difference.
])
