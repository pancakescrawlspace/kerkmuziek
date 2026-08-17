#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// Exploded score (one voice per part, from tools/voice-explode.py) with the
// Soprano line colored red via tools/voice-colorize.py -- study your part
// while still seeing what the other three are doing.

#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, Soprano highlighted])
#v(12pt)

#score(
  read("../musicxml/four-voices.exploded.soprano.musicxml"),
  options: (header: "none", adjust-page-width: true),
  width: 100%,
)
