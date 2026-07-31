// hold(...) underlines a syllable held on a longer note. Built directly on
// Typst's own `underline()`, which already draws a rule at a fixed offset
// below the baseline -- so, unlike the pitch marks in pitch-marks.typ, no
// manual box measuring is needed here at all.
//
// `extent` is negative to shrink the rule so that two adjacent held
// syllables leave a visible gap between their underlines rather than
// joining into one line (mirroring the TeX version's \holdgap).

#let hold-thickness = 1.3pt
#let hold-offset = 3pt        // how far below the baseline the underline sits
#let hold-gap = 4pt           // shrink the underline by this much in total

#let hold(body) = underline(
  body,
  stroke: hold-thickness,
  offset: hold-offset,
  extent: -hold-gap / 2,
  evade: false,
)

// The mirror image of hold: extends the rule *beyond* the syllable on each
// side instead of falling short, for a syllable that should read as held
// even wider than its own width.
#let hold-wide(body) = underline(
  body,
  stroke: hold-thickness,
  offset: hold-offset,
  extent: hold-gap / 2,
  evade: false,
)

// Underlines the syllable's full width exactly, neither shortened (hold) nor
// lengthened (hold-wide).
#let hold-exact(body) = underline(
  body,
  stroke: hold-thickness,
  offset: hold-offset,
  extent: 0pt,
  evade: false,
)
