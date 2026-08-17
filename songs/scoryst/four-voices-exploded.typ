#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// copied from four-voices.typ

#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, simple demo harmonization])
#v(12pt)

#score(
  read("../musicxml/four-voices.exploded.musicxml"),
  options: (header: "none", adjust-page-width: true),
  width: 100%,
)
