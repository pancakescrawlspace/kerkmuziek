#import "@preview/typed-scores:0.3.0": score

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica", size: 11pt)

// "Twinkle, Twinkle, Little Star" arranged for SATB -- same harmonization as
// songs/scoryst/four-voices.typ (parallel diatonic thirds in the inner
// voices, root-motion bass), rebuilt here with typed-scores so the two
// packages can be compared on the same piece. Each staff carries two
// independent-rhythm voices (an array of two note strings per bar: voice 1
// stems up, voice 2 stems down), rather than MusicXML's separate <voice>/
// <staff> elements.
#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, simple demo harmonization])
#v(12pt)

#score(
  staves: (
    upper: (clef: "treble", label: "Soprano / Alto", short-label: "S / A"),
    lower: (clef: "bass", label: "Tenor / Bass", short-label: "T / B"),
  ),
  key: "C",
  time: "4/4",
  bars: (
    (
      upper: ("c4:q c4:q g4:q g4:q", "a3:q a3:q e4:q e4:q"),
      lower: ("f3:q f3:q c4:q c4:q", "c2:q c2:q g2:q g2:q"),
      lyrics: (upper: "Twin -- kle, twin -- kle,"),
    ),
    (
      upper: ("a4:q a4:q g4:h", "f4:q f4:q e4:h"),
      lower: ("d4:q d4:q c4:h", "a2:q a2:q g2:h"),
      lyrics: (upper: "lit -- tle star,"),
    ),
    (
      upper: ("f4:q f4:q e4:q e4:q", "d4:q d4:q c4:q c4:q"),
      lower: ("b3:q b3:q a3:q a3:q", "f2:q f2:q c2:q c2:q"),
      lyrics: (upper: "How I won -- der"),
    ),
    (
      upper: ("d4:q d4:q c4:h", "b3:q b3:q a3:h"),
      lower: ("g3:q g3:q f3:h", "g2:q g2:q c2:h"),
      lyrics: (upper: "what you are!"),
    ),
    (
      upper: ("g4:q g4:q f4:q f4:q", "e4:q e4:q d4:q d4:q"),
      lower: ("c4:q c4:q b3:q b3:q", "g2:q g2:q f2:q f2:q"),
      lyrics: (upper: "Up a -- bove the"),
    ),
    (
      upper: ("e4:q e4:q d4:h", "c4:q c4:q b3:h"),
      lower: ("a3:q a3:q g3:h", "c2:q c2:q g2:h"),
      lyrics: (upper: "world so high,"),
    ),
    (
      upper: ("g4:q g4:q f4:q f4:q", "e4:q e4:q d4:q d4:q"),
      lower: ("c4:q c4:q b3:q b3:q", "g2:q g2:q f2:q f2:q"),
      lyrics: (upper: "Like a dia -- mond"),
    ),
    (
      upper: ("e4:q e4:q d4:h", "c4:q c4:q b3:h"),
      lower: ("a3:q a3:q g3:h", "c2:q c2:q g2:h"),
      lyrics: (upper: "in the sky."),
    ),
    (
      upper: ("c4:q c4:q g4:q g4:q", "a3:q a3:q e4:q e4:q"),
      lower: ("f3:q f3:q c4:q c4:q", "c2:q c2:q g2:q g2:q"),
      lyrics: (upper: "Twin -- kle, twin -- kle,"),
    ),
    (
      upper: ("a4:q a4:q g4:h", "f4:q f4:q e4:h"),
      lower: ("d4:q d4:q c4:h", "a2:q a2:q g2:h"),
      lyrics: (upper: "lit -- tle star,"),
    ),
    (
      upper: ("f4:q f4:q e4:q e4:q", "d4:q d4:q c4:q c4:q"),
      lower: ("b3:q b3:q a3:q a3:q", "f2:q f2:q c2:q c2:q"),
      lyrics: (upper: "How I won -- der"),
    ),
    (
      upper: ("d4:q d4:q c4:h", "b3:q b3:q a3:h"),
      lower: ("g3:q g3:q f3:h", "g2:q g2:q c2:h"),
      lyrics: (upper: "what you are!"),
    ),
  ),
)
