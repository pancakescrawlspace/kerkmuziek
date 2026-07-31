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
// The fix is the same trick used for mark-above in pitch-marks.typ, plus
// one more step: an explicit `baseline` on the box, computed purely from
// hold-clearance/hold-thickness (never from the content), so the result is
// identical whether body is real letters or blank space. That explicit
// value was found by comparing renders of this construction against
// Typst's own automatic baseline for ordinary text (where the automatic
// choice is correct) until the two matched pixel-for-pixel; it is not
// derived from font metrics, since Typst does not expose the ascent/descent
// split needed to compute it directly.
#let hold-thickness = 1.3pt
#let hold-clearance = 1.5pt   // gap between the syllable's own bottom edge and the rule
#let hold-gap = 4pt           // shrink/extend the rule by this much in total

#let hold-below(delta, body) = context {
  let w = measure(body).width
  let len = w + delta
  // Force the box's own layout width to the syllable's width, same as the
  // syllable alone would take up: hold-wide's rule is longer than the
  // syllable and would otherwise widen the box, consuming extra horizontal
  // space and shifting where the paragraph wraps (observed as "gering"
  // splitting into "geri"/"ng" across a line break that TeX's \rlap-based
  // \holdwide never introduced, since \rlap never consumes width). The
  // wider rule still renders in full -- Typst does not clip a box's
  // overflowing content by default -- it just no longer counts against
  // line-breaking.
  box(width: w, baseline: (at: bottom, shift: hold-clearance + hold-thickness), stack(dir: ttb, spacing: hold-clearance,
    body,
    align(center, line(start: (0pt, 0pt), end: (len, 0pt), stroke: hold-thickness)),
  ))
}

#let hold(body) = hold-below(-hold-gap, body)

// The mirror image of hold: extends the rule *beyond* the syllable on each
// side instead of falling short, for a syllable that should read as held
// even wider than its own width.
#let hold-wide(body) = hold-below(hold-gap, body)

// Underlines the syllable's full width exactly, neither shortened (hold) nor
// lengthened (hold-wide).
#let hold-exact(body) = hold-below(0pt, body)
