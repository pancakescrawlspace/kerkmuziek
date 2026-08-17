#import "@preview/scoryst:0.1.3": score, pages

#set page(paper: "a4", margin: 1in, numbering: none)

// copied from four-voices.typ

#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, simple demo harmonization])
#v(12pt)

// Four staves per system (one per voice) need more vertical space than the
// two-staff scores elsewhere in this file, so Verovio's adjustPageHeight
// (on by default) paginates internally past 1 page here. scoryst's score()
// only ever renders the page you ask for (default page: 1), so without this
// loop everything past page 1 -- more than half this piece -- is silently
// dropped. pages() reports how many Verovio pages there are; render each.
#let data = read("../musicxml/four-voices.exploded.musicxml")
#let opts = (header: "none", adjust-page-width: true)
#for p in range(1, pages(data, options: opts) + 1) [
  #if p > 1 [ #pagebreak() ]
  #score(data, options: opts, page: p, width: 100%)
]
