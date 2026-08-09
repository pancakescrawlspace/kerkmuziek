#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// Alternative to twinkle-twinkle.typ: the same song, but the notes and lyrics
// come from an external MusicXML file instead of inline ABC notation. scoryst's
// `score` accepts the file's raw text (read here with Typst's `read`) and hands
// it to its bundled Verovio engraver, which auto-detects the input format.
// See twinkle-twinkle.musicxml for a heavily annotated walk-through of the
// MusicXML structure.
// `lyric-word-space` (Verovio's lyricWordSpace, in staff-space units) sets the
// minimum gap between separate lyric words. The default leaves "How I" and
// "what you" looking cramped here; 1.6 gives them room while keeping the music
// on two systems. See the note below about why this needs setting explicitly.
#score(
  read("twinkle-twinkle.musicxml"),
  options: (lyric-word-space: 1.6),
  width: 100%,
)
