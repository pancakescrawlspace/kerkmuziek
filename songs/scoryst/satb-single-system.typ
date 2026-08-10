#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// Render all text in Helvetica. This covers both the Typst-drawn title and the
// score's own text (lyrics, part labels): scoryst emits the score's text as SVG
// <text> elements, so Typst's text font applies to them too.
#set text(font: "Helvetica")

// A single system with two staves: Soprano/Alto on the treble staff,
// Tenor/Bass on the bass staff, braced together. The music (three measures)
// is short enough that Verovio lays it out on one system. See
// satb-single-system.musicxml for how the two staves and the two voices per
// staff are encoded.
#align(center, text(weight: "bold", size: 16pt)[A Little SATB Phrase])
#v(12pt)

// Enlarge the score by a constant factor.
//
// `#scale` does NOT work here: scoryst returns an auto-sized SVG `image` that
// fills the text column (padded on the right with Verovio's uncropped page), so
// scaling just re-fills the same box and nothing grows. The size knob is the
// image's `width` instead. `adjust-page-width: true` crops that right-hand
// padding so the width drives the music itself, not the empty page.
//
// `base` is the width at which the cropped score matches its default (un-widthed)
// drawn size, so `factor` reads as a plain multiplier: 1.0 = as-is, 1.5 = 150%.
// It is derived from the file, not hard-coded, so it still holds if the MusicXML
// changes. The default size is the cropped music shrunk to fit inside Verovio's
// uncropped page, i.e. (cropped width / uncropped width) of the text column;
// `layout` supplies that column width. Above ~2.0 the system starts to exceed
// the A4 portrait column.
//
// `word-space` is Verovio's `lyricWordSpace`: the MINIMUM gap between lyric
// words, in staff-space units (default 1.2). Doubling it to 2.4 enforces a
// minimum at least twice the default, opening up the crowded middle words
// ("now sing with great"). Words the notes already space out stay put, as a
// minimum should. It is threaded through every `score` call so the width
// measurements match the final render.
#let factor = 1.5
#let word-space = 2.4
#let music = read("satb-single-system.musicxml")
#let opts = (adjust-page-width: true, lyric-word-space: word-space)
#layout(size => {
  let cropped = measure(score(music, options: opts)).width
  let uncropped = measure(score(music, options: (lyric-word-space: word-space))).width
  let base = cropped / uncropped * size.width
  align(center, score(
    music,
    options: opts,
    width: base * factor,
  ))
})
