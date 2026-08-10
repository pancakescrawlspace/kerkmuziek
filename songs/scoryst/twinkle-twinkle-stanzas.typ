#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// A variant of twinkle-twinkle.typ: the same inline-ABC score, followed by the
// song's stanzas printed as running text beneath the music. The score below is
// an unchanged copy of twinkle-twinkle.typ; only the text block underneath is
// new. (Placeholder verses: the score's own lyric line, de-hyphenated and
// repeated four times, standing in for the real additional stanzas.)

#score(
  "X:1
T:Twinkle, Twinkle, Little Star
M:4/4
L:1/4
K:C
C C G G | A A G2 |
w: Twin-kle twin-kle lit-tle star,
F F E E | D D C2 |
w: How I won-der what you are!
G G F F | E E D2 |
w: Up a-bove the world so high,
G G F F | E E D2 |
w: Like a dia-mond in the sky.
C C G G | A A G2 |
w: Twin-kle twin-kle lit-tle star,
F F E E | D D C2 |]
w: How I won-der what you are!",
  width: 100%,
)

#v(24pt)

// The stanza text (the score's lyrics, de-hyphenated). `\` breaks lines within
// the block; Typst wrapping is free, unlike inside the score.
#let verse = [
  Twinkle twinkle little star, \
  How I wonder what you are! \
  Up above the world so high, \
  Like a diamond in the sky. \
  Twinkle twinkle little star, \
  How I wonder what you are!
]

// Print the verse four times, each numbered and centred, with space between.
#for n in range(1, 5) {
  align(center, block(breakable: false, {
    text(weight: "bold")[#n.]
    v(0.35em, weak: true)
    verse
  }))
  v(1.4em, weak: true)
}
