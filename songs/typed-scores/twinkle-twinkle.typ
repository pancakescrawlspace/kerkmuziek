#import "@preview/typed-scores:0.3.0": score

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica", size: 11pt)

#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#v(12pt)

#score(
  clef: "treble",
  key: "C",
  time: "4/4",
  lyric-size: 2.2,   // default is 0.9 (~7pt); this gives ~18pt, readable across a choir stand
  lyric-gap: 1.4,    // extra clearance between staff and the larger lyric text
  verse-gap: 2.5,    // must stay >= lyric-size
  bars: (
    (notes: "c5:q c5 g5 g5", lyrics: "Twin -- kle, twin -- kle,"),
    (notes: "a5 a5 g5:h", lyrics: "lit -- tle star,"),
    (notes: "f5:q f5 e5 e5", lyrics: "How I won -- der"),
    (notes: "d5 d5 c5:h", lyrics: "what you are!"),
    (notes: "g5:q g5 f5 f5", lyrics: "Up a -- bove the"),
    (notes: "e5 e5 d5:h", lyrics: "world so high,"),
    (notes: "g5:q g5 f5 f5", lyrics: "Like a dia -- mond"),
    (notes: "e5 e5 d5:h", lyrics: "in the sky."),
    (notes: "c5:q c5 g5 g5", lyrics: "Twin -- kle, twin -- kle,"),
    (notes: "a5 a5 g5:h", lyrics: "lit -- tle star,"),
    (notes: "f5:q f5 e5 e5", lyrics: "How I won -- der"),
    (notes: "d5 d5 c5:h", lyrics: "what you are!"),
  ),
)
