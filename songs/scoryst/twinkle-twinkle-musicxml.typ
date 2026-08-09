#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// Alternative to twinkle-twinkle.typ: the same song, but the notes and lyrics
// come from an external MusicXML file instead of inline ABC notation. scoryst's
// `score` accepts the file's raw text (read here with Typst's `read`) and hands
// it to its bundled Verovio engraver, which auto-detects the input format.
// See twinkle-twinkle.musicxml for a heavily annotated walk-through of the
// MusicXML structure.
#score(
  read("twinkle-twinkle.musicxml"),
  width: 100%,
)
