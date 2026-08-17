#import "@preview/scoryst:0.1.3": score, pages

#set page(paper: "a4", margin: 1in, numbering: none)

// Exploded score (one voice per part, from tools/voice-explode.py) with the
// Tenor line colored red via tools/voice-colorize.py -- study your part
// while still seeing what the other three are doing.

#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, Tenor highlighted])
#v(12pt)

// Four staves per system need more vertical space than this file's scores
// elsewhere, so Verovio paginates internally past 1 page -- score() only
// ever renders the page you ask for, so loop over all of them or lose
// everything past page 1. See four-voices-exploded.typ for the long version.
#let data = read("../musicxml/four-voices.exploded.tenor.musicxml")
#let opts = (header: "none", adjust-page-width: true)
#for p in range(1, pages(data, options: opts) + 1) [
  #if p > 1 [ #pagebreak() ]
  #score(data, options: opts, page: p, width: 100%)
]
