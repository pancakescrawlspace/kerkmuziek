#import "../../tools/typst/svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// scoryst-free counterpart of songs/scoryst/twinkle-fugue.typ.
#align(center, text(weight: "bold", size: 16pt)[Fugue à 3])
#align(center, text(size: 11pt, style: "italic")[on "Twinkle, Twinkle, Little Star"])
#v(14pt)

#let prefix = "/songs/musicxml-svg/twinkle-fugue"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]
