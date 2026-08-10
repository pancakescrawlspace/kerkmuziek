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
// words, in staff-space units (default 1.2). Raising it to 3.0 (2.5x the
// default) enforces a wider minimum, opening up the crowded middle words
// ("now sing with great"). Words the notes already space out stay put, as a
// minimum should. It is threaded through every `score` call so the width
// measurements match the final render.
#let factor = 1.5
#let word-space = 3.0
#let music = read("satb-single-system.musicxml")
#let opts = (adjust-page-width: true, lyric-word-space: word-space)

// A performance instruction drawn OVER the score rather than encoded in the
// MusicXML, which stays pure musical content. scoryst returns the score as an
// opaque SVG image, so the text is positioned against measured anchors, each a
// fraction of the image so they scale with the score:
//   - `text-left`  : the text's left edge over bar 2, tuned to taste. For
//                    reference, bar 2's barline is at 0.429 and beat 1's stems
//                    are at 0.448 (alto, down) and 0.467 (soprano, up); this
//                    sits a little right of those, comfortably inside bar 2;
//   - `lyric-frac` : the lyric glyph size, so the text matches the lyrics;
//   - `staff-top`  : where the music's top edge sits within the image;
//   - `gap`        : the space left between the text and the staff.
// These were measured once from this score (see the sibling MusicXML). They do
// NOT track edits to the music -- if the notes change, re-measure them. Line
// wrapping, on the other hand, is free here: `\` starts a new line, something
// Verovio cannot do in a <direction>. See the git history for the MusicXML
// <direction> alternative.
#let instruction = [Singers wave \ their hands.]
#let text-left = 48.6%
#let lyric-frac = 3.59%
#let staff-top = 14.2%
#let gap = 3pt

#layout(size => {
  let cropped = measure(score(music, options: opts)).width
  let uncropped = measure(score(music, options: (lyric-word-space: word-space))).width
  let base = cropped / uncropped * size.width
  let img = score(music, options: opts, width: base * factor)
  let dims = measure(img)

  // The annotation as its own measured block: left-justified, sized to match the
  // lyrics (lyric-frac of the music width).
  let note = box(text(style: "italic", size: lyric-frac * dims.width,
    align(left, instruction)))
  let nd = measure(note)

  // Desired top of the text: `gap` above the music's top edge. If that would
  // poke above the image, reserve just that overflow as a band on top.
  let y = staff-top * dims.height - gap - nd.height
  let band = if y < 0pt { -y } else { 0pt }

  // `place` is out-of-flow, so both the score and the text float inside one box
  // without disturbing each other. The text is anchored by its left edge.
  align(center, box(width: dims.width, height: dims.height + band, {
    place(bottom + left, img)
    place(top + left, dx: text-left * dims.width, dy: band + y, note)
  }))
})
