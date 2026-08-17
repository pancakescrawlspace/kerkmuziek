#import "svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// scoryst-free counterpart of songs/scoryst/twinkle-fugue.typ.
//
// Its SVG must be (re)generated with --option minLastJustification=0, or
// the last system renders short of the right margin instead of stretched to
// full width like scoryst's -- scoryst's bundled Verovio build always
// justifies the last system; ours only does so above minLastJustification's
// default 80%-of-width threshold, which this piece's last system falls
// under:
//   python3 tools/musicxml2svg.py songs/musicxml/twinkle-fugue.musicxml \
//     songs/musicxml-svg/twinkle-fugue --option minLastJustification=0
#align(center, text(weight: "bold", size: 16pt)[Fugue à 3])
#align(center, text(size: 11pt, style: "italic")[on "Twinkle, Twinkle, Little Star"])
#v(14pt)

#let prefix = "/songs/musicxml-svg/twinkle-fugue"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]
