// hold(...) underlines a syllable held on a longer note.
//
// The rule is drawn as a plain line(), not Typst's own underline(): that
// decoration turns out to misplace itself badly -- floating up near
// x-height instead of sitting below the baseline -- whenever the decorated
// content has no visible ink (e.g. a syllable made only of spaces, used to
// carry a mark/hold with no letters under it; see makrina.typ's
// "Makri-~~~~~~~" line). Typst's own box measurements are consistent
// regardless of content (a box around "x", "hA" or three non-breaking
// spaces all measure to the same height -- font metrics, not per-glyph
// ink), but its *automatic* choice of a box's inline baseline is not: for
// invisible content it picks the wrong reference point.
//
// Two earlier versions of this file got the rule's placement wrong in two
// different ways -- worth recording since both looked fine until checked
// closely:
//
// - One gave the box an explicit `baseline: (at: bottom, shift:
//   hold-clearance + hold-thickness)`, found by eye-matching a render
//   against plain text. The number was wrong: it substituted the rule's own
//   thickness for the body's font descent (the gap between its baseline and
//   the bottom of its own metrics box, which is what the box's bottom edge
//   actually sits `hold-clearance` below), and a font's descent is several
//   times an underline's stroke width. Every held syllable sat too high by
//   (descent - hold-thickness).
// - The next version stacked body directly above a bare, undecorated
//   line() and let Typst's automatic baseline detection handle the rest --
//   which does work, confirmed next to plain text down to the pixel,
//   *provided* the line's own start point is exactly (0pt, 0pt). The
//   moment the rule needs centering under a body narrower or wider than it
//   (shrunk for `hold`, widened for `hold-wide`) and picks up any nonzero
//   horizontal offset -- however it's applied: line() coordinates, pad(),
//   align(), a grid cell -- that detection breaks and every held syllable
//   sits too high again, by a gap that shrinks as the font grows (so a
//   60pt test render looked fine and an 18pt one, matching this document's
//   actual body size, didn't). Root cause not fully diagnosed -- Typst's
//   stack() apparently keys its baseline forwarding to a child sitting flush
//   at the cross-axis origin, and a centered rule never does regardless of
//   how the centering is achieved.
//
// The fix sidesteps the whole question: body is the box's only *flow*
// child (still auto-detects correctly, alone), and the rule is a place()
// overlay instead of a stack sibling -- place() doesn't participate in
// that detection at all, so its own horizontal offset can't disturb it.
// The box's bottom inset reserves the room the rule is drawn into, since
// place() itself doesn't grow the box the way a stack child would.
//
// `place(bottom, ...)` with no further offset lands the rule exactly at
// body's own bottom edge (its font-metric descent line) -- not below it --
// so without the `dy` shift below, the rule would sit flush against body
// instead of leaving hold-clearance of daylight, running straight through
// letters with a deep descender. The shift needs half the stroke's own
// thickness added on top of hold-clearance because the stroke is centered
// on the line's path, not drawn above it -- otherwise half the stroke
// would still eat into that gap.
#let hold-color = red
#let hold-thickness = 1.3pt
#let hold-clearance = 1.5pt   // gap between the syllable's own bottom edge and the rule
#let hold-gap = 4pt           // shrink/extend the rule by this much in total

#let hold-below(delta, body) = context {
  let w = measure(body).width
  let len = w + delta
  let x0 = (w - len) / 2
  // Force the box's own layout width to the syllable's width, same as the
  // syllable alone would take up: hold-wide's rule is longer than the
  // syllable and would otherwise widen the box, consuming extra horizontal
  // space and shifting where the paragraph wraps (observed as "gering"
  // splitting into "geri"/"ng" across a line break that TeX's \rlap-based
  // \holdwide never introduced, since \rlap never consumes width). The
  // wider rule still renders in full -- Typst does not clip a box's
  // overflowing content by default -- it just no longer counts against
  // line-breaking.
  //
  // The rule is drawn before body, not after: Typst paints box content in
  // document order, so whichever comes last ends up on top. Letters with a
  // descender that reaches into the clearance gap (e.g. "g") should have
  // their own black ink cover the red rule there, not the other way
  // around, so body has to be the one painted last.
  box(width: w, inset: (bottom: hold-clearance + hold-thickness))[
    #place(bottom, dx: x0, dy: hold-clearance + hold-thickness / 2, line(start: (0pt, 0pt), end: (len, 0pt), stroke: (paint: hold-color, thickness: hold-thickness)))
    #body
  ]
}

#let hold(body) = hold-below(-hold-gap, body)

// The mirror image of hold: extends the rule *beyond* the syllable on each
// side instead of falling short, for a syllable that should read as held
// even wider than its own width.
#let hold-wide(body) = hold-below(hold-gap, body)

// Underlines the syllable's full width exactly, neither shortened (hold) nor
// lengthened (hold-wide).
#let hold-exact(body) = hold-below(0pt, body)
