#import "../../tools/typst/svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// scoryst-free counterpart of songs/scoryst/hidden-fifths-octaves.typ.
#align(center, text(weight: "bold", size: 16pt)[Hidden (Direct) Fifths & Octaves])
#align(center, text(size: 11pt, style: "italic")[the subtler cousin of parallels])
#v(14pt)

#let prefix = "/songs/musicxml-svg/hidden-fifths-octaves"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]

#v(18pt)

#set text(size: 10pt)
#block(width: 100%, [
  *What is going on.* A _hidden_ (or _direct_) fifth/octave is not two perfect
  intervals in a row -- it is *arriving* at a perfect fifth or octave by *similar
  motion* (both voices moving the same way). It is chiefly a fault between the
  *outer voices* when the *top voice leaps* into the perfect interval: the ear
  fills in the skipped note and hears a latent parallel. In example 1 the
  soprano's D→G leap over the bass's F→G step implies the parallel octave
  F→G / F→G that a stepwise line would have spelled out.

  *The fixes.* Approach the perfect interval by *contrary motion* (example 2), or
  let the *top voice move by step* (example 4 is accepted even though both voices
  rise, because the soprano only steps -- the leap is in the bass). Unlike the
  blatant parallels of the sibling demo, this fault is more *visible than
  audible*, so read the motion as much as you listen to
  *hidden-fifths-octaves.mid*.
])
