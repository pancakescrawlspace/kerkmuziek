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

// Height contributed by a stroke-column of `count` stacked strokes -- for
// sizing the space mark-above reserves above body. Not measured off the
// mark itself: `measure()` reports a bare `line()` as zero-height
// regardless of slope (only start/end.x feed into it), so a diagonal
// up-/down-stroke would otherwise be treated as flat. Computed from the
// same constants the strokes are drawn with instead.
#let mark-column-height(count) = count * rise-height + (count - 1) * mark-stack-gap

// Place `mark` above `body` without disturbing body's own position or
// baseline: body is the box's only flow content (so it keeps exactly the
// baseline it would have alone, held syllable or not -- see hold.typ's own
// comment for why that matters), and mark is a place() overlay floating in
// space the box's top inset reserves for it, sized from `mark-height`
// (see mark-column-height above for why that can't just be measured).
//
// This route -- rather than the more obvious `stack(dir: ttb, mark, body)`
// -- exists because that stack() only forwards a correct baseline to the
// box wrapping it when it can read one straight off a plain child. A body
// with any internal structure of its own throws that off -- concretely,
// hold.typ's rule is a place() overlay inside body rather than a plain run
// of text -- and the held syllable then sits noticeably higher than its
// neighbors. Wrapping body in its own inner box didn't fix it either: the
// stack still has mark as a second, sibling child, and that alone is
// enough to break the detection regardless of how body itself is wrapped.
// Removing the stack (and mark as a sibling in it) entirely was the only
// approach that held up under both a bare `hold[geest]` and one nested
// under a mark, checked against plain text down to the pixel.
#let mark-above(mark, mark-height, body, align-mark: center) = context {
  let bw = measure(body).width
  let mw = measure(mark).width
  let w = calc.max(bw, mw)
  let dx = if align-mark == left { 0pt } else { (w - mw) / 2 }
  box(width: w, inset: (top: mark-height + mark-clearance))[
    #body
    #place(top, dx: dx, dy: -(mark-height + mark-clearance), mark)
  ]
}

// ---- pitch marks --------------------------------------------------------

#let rise(body) = mark-above(up-stroke, rise-height, body)
#let risetwo(body) = mark-above(stroke-column(up-stroke, count: 2), mark-column-height(2), body)
#let risethree(body) = mark-above(stroke-column(up-stroke, count: 3), mark-column-height(3), body)

#let fall(body) = mark-above(down-stroke, rise-height, body)
#let falltwo(body) = mark-above(stroke-column(down-stroke, count: 2), mark-column-height(2), body)
#let fallthree(body) = mark-above(stroke-column(down-stroke, count: 3), mark-column-height(3), body)

// Several strokes over one syllable, each a separate note (side by side, not stacked).
// A row is exactly as tall as one stroke, however many sit side by side.
#let risetwice(body) = mark-above(stroke-row(up-stroke, count: 2), rise-height, body)
#let falltwice(body) = mark-above(stroke-row(down-stroke, count: 2), rise-height, body)
#let fallthreespaced(body) = mark-above(stroke-row(down-stroke, count: 3), rise-height, body)

// Level (unchanging) pitch: a short flat bar over the syllable.
#let level(body) = mark-above(flat-stroke, 0pt, body)

// A row of arbitrary strokes (mix up-stroke/down-stroke/flat-stroke), flush
// left over the syllable instead of centred -- for runs like "three falls
// then a rise" over one long syllable. Assumes the row includes at least
// one sloped stroke (true of every use in makrina.typ), same height as a
// single stroke either way.
#let spaced-left(strokes, body) = mark-above(
  stack(dir: ltr, spacing: mark-spaced-gap, ..strokes), rise-height, body, align-mark: left,
)
