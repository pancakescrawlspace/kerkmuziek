#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// A single system with two staves: Soprano/Alto on the treble staff,
// Tenor/Bass on the bass staff, braced together. The music (three measures)
// is short enough that Verovio lays it out on one system. See
// satb-single-system.musicxml for how the two staves and the two voices per
// staff are encoded.
#align(center, text(weight: "bold", size: 16pt)[A Little SATB Phrase])
#v(12pt)

// `adjust-page-width` shrinks Verovio's page to the music's natural width, so
// this short single system then scales up to fill the page (width: 100%) rather
// than sitting small at the left. It also gives the lyrics room to breathe.
#score(
  read("satb-single-system.musicxml"),
  options: (adjust-page-width: true),
  width: 100%,
)
