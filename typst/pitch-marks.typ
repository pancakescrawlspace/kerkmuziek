// Pitch marks above syllables. A rising pitch is marked with one or more
// rising diagonal strokes and a falling pitch with falling ones. A level
// (unchanging) pitch gets a short flat bar instead. \risetwo/\risethree
// (stroke-column) stack two/three strokes vertically; \risetwice etc.
// (stroke-row) place them side by side, one note each.
//
// Unlike the TeX version this replaces -- which had to fake a 45-degree
// diagonal with a \pdfliteral path, then later with borrowed font glyphs,
// because \hrule/\vrule can't draw diagonals and a font's own glyph shapes
// are whatever the type designer drew -- Typst can draw a line at an exact
// angle directly (`line(start:, end:)`). So the stroke's angle, length and
// thickness below are just numbers to tune, with no glyph or driver trick
// involved.
//
// hold.typ (the underline for held syllables) is independent but composes
// with these, e.g. rise(hold[geest]) draws a stroke above and an underline
// below the same syllable.

// ---- tunable parameters ---------------------------------------------------

#let mark-color = red
#let mark-thickness = 1.3pt
#let mark-length = 7pt        // horizontal run of one stroke
#let mark-slope = 0.5         // rise/run of one stroke (0.5 => ~27deg, 1 => 45deg)
#let mark-clearance = 3pt     // gap between the syllable's top and the mark
#let mark-stack-gap = 1.5pt   // vertical gap between stacked strokes (risetwo/risethree)
#let mark-spaced-gap = 3pt    // horizontal gap between side-by-side strokes over one syllable

// ---- stroke primitives ------------------------------------------------------

#let mark-stroke = (paint: mark-color, thickness: mark-thickness, cap: "round")
#let rise-height = mark-length * mark-slope

#let up-stroke = line(start: (0pt, 0pt), end: (mark-length, -rise-height), stroke: mark-stroke)
#let down-stroke = line(start: (0pt, 0pt), end: (mark-length, rise-height), stroke: mark-stroke)
#let flat-stroke = line(start: (0pt, 0pt), end: (mark-length, 0pt), stroke: mark-stroke)

// `count` copies of `stroke`, side by side (one note each) -- for the "spaced" variants.
#let stroke-row(stroke, count: 1) = {
  if count == 1 { stroke } else {
    stack(dir: ltr, spacing: mark-spaced-gap, ..range(count).map(_ => stroke))
  }
}

// `count` copies of `stroke`, stacked directly one above another -- for risetwo/risethree.
#let stroke-column(stroke, count: 1) = {
  if count == 1 { stroke } else {
    stack(dir: ttb, spacing: mark-stack-gap, ..range(count).map(_ => stroke))
  }
}

// ---- overlay core -----------------------------------------------------------

// Overlay `mark` above `body` without consuming any of its own horizontal
// space: a negative-spacing stack pulls the mark up so it sits
// mark-clearance above the syllable rather than after it.
//
// This also gives every mark the same height above the baseline for free:
// Typst boxes a run of same-size, same-font text to a fixed ascent/descent
// (font metrics), not to the ink height of whichever letters happen to be in
// it -- so "x", "hA" and "g" all measure the same box height. The TeX
// version had to measure that height once by hand (\hbox{Ahg}) and store it
// in \riseheight because \hbox there sizes to each glyph's own metrics;
// here it falls out of how Typst lays out text.
#let mark-above(mark, body, align-mark: center) = box(stack(dir: ttb, spacing: -mark-clearance,
  align(align-mark, mark),
  body,
))

// ---- pitch marks --------------------------------------------------------

#let rise(body) = mark-above(up-stroke, body)
#let risetwo(body) = mark-above(stroke-column(up-stroke, count: 2), body)
#let risethree(body) = mark-above(stroke-column(up-stroke, count: 3), body)

#let fall(body) = mark-above(down-stroke, body)
#let falltwo(body) = mark-above(stroke-column(down-stroke, count: 2), body)
#let fallthree(body) = mark-above(stroke-column(down-stroke, count: 3), body)

// Several strokes over one syllable, each a separate note (side by side, not stacked).
#let risetwice(body) = mark-above(stroke-row(up-stroke, count: 2), body)
#let falltwice(body) = mark-above(stroke-row(down-stroke, count: 2), body)
#let fallthreespaced(body) = mark-above(stroke-row(down-stroke, count: 3), body)

// Level (unchanging) pitch: a short flat bar over the syllable.
#let level(body) = mark-above(flat-stroke, body)

// A row of arbitrary strokes (mix up-stroke/down-stroke/flat-stroke), flush
// left over the syllable instead of centred -- for runs like "three falls
// then a rise" over one long syllable.
#let spaced-left(strokes, body) = mark-above(
  stack(dir: ltr, spacing: mark-spaced-gap, ..strokes), body, align-mark: left,
)
