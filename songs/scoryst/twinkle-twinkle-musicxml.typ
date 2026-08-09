#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// Alternative to twinkle-twinkle.typ: the same song, but the notes and lyrics
// come from an external MusicXML file instead of inline ABC notation. scoryst's
// `score` accepts the file's raw text (read here with Typst's `read`) and hands
// it to its bundled Verovio engraver, which auto-detects the input format.
// See twinkle-twinkle.musicxml for a heavily annotated walk-through of the
// MusicXML structure.
// The title is typeset here in Typst, matching four-voices.typ. Its MusicXML
// counterpart is <work-title>, but scoryst's Verovio mis-centers that element
// and its `header` option won't suppress it, so the title is left out of the
// XML and drawn here instead (see the note in twinkle-twinkle.musicxml).
#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#v(12pt)

// `lyric-word-space` (Verovio's lyricWordSpace, in staff-space units) sets the
// minimum gap between separate lyric words. The default leaves "How I" and
// "what you" looking cramped here; 1.6 gives them room while keeping the music
// on two systems.
#score(
  read("twinkle-twinkle.musicxml"),
  options: (lyric-word-space: 1.6),
  width: 100%,
)
