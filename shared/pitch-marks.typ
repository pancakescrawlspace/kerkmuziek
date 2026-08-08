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

#let mark-color = luma(90)
#let mark-thickness = 1.3pt
#let mark-length = 7pt        // horizontal run of one stroke
#let mark-slope = 0.5         // rise/run of one stroke (0.5 => ~27deg, 1 => 45deg)
// State, not a plain length: mark-above reads it back via .get() inside its
// own context block, so a caller can override it with mark-clearance.update()
// after importing this file. A plain #let here would still let another file
// write `#let mark-clearance = ...`, but that only shadows the name in the
// *importing* file's own scope -- mark-above's closure was defined in this
// module and keeps resolving mark-clearance to this module's own binding
// regardless, so the override would silently do nothing.
#let mark-clearance = state("pitch-marks-mark-clearance", 3pt) // gap between the syllable's top and the mark
#let mark-stack-gap = .75pt   // vertical gap between stacked strokes (risetwo/risethree)
#let mark-spaced-gap = 3pt    // horizontal gap between side-by-side strokes over one syllable

// ---- stroke primitives ------------------------------------------------------

#let mark-stroke = (paint: mark-color, thickness: mark-thickness, cap: "round")
#let rise-height = mark-length * mark-slope

// Every stroke/mark is represented as a dictionary of `shape` (the drawable
// content) plus `low`/`high`: how far below/above the shape's own local
// origin -- the point place() actually positions -- its lowest and highest
// ink sit. mark-above (below) uses these to line up every mark's *lowest*
// point across a document at the same height, rather than their local
// origins: a `line()`'s origin is just wherever its `start` was written,
// with no relation to which end draws higher or lower, so treating origins
// as interchangeable (as this file did before) aligns up-stroke and
// down-stroke by their *left* ends instead -- which happen to be their low
// end and high end respectively, an inch-perfect match only by coincidence
// of which one bottoms out where. Explicit `low`/`high` fields make the
// alignment about the ink, not about which end of the line happened to be
// written first.
//
// up-stroke rises away from its own origin, so that origin already is its
// low point (low: 0pt) and the far end, a full rise-height higher, is the
// high point. down-stroke is the mirror image: its origin is already the
// high point, and its low point is a rise-height below it. flat-stroke has
// no ink above or below its one drawn height at all, but still needs a
// `low`/`high` pair to slot into the same alignment scheme as the sloped
// strokes: by the tunable-parameters comment's own definition, "aligned
// with respect to the other two" means level's one drawn height should
// coincide with the vertical midpoint between a sloped stroke's low and
// high points, i.e. rise-height/2 below where that stroke's low point
// would sit -- so low and high are both set to rise-height/2, the "no
// span, sits at the midpoint" case.
#let up-stroke = (
  shape: line(start: (0pt, 0pt), end: (mark-length, -rise-height), stroke: mark-stroke),
  low: 0pt,
  high: -rise-height,
)
#let down-stroke = (
  shape: line(start: (0pt, 0pt), end: (mark-length, rise-height), stroke: mark-stroke),
  low: rise-height,
  high: 0pt,
)
#let flat-stroke = (
  shape: line(start: (0pt, 0pt), end: (mark-length, 0pt), stroke: mark-stroke),
  low: rise-height / 2,
  high: rise-height / 2,
)

// Same drawn line as flat-stroke, but aligned with the *bottom* of the two
// diagonal strokes instead of their vertical midpoint. up-stroke and
// down-stroke share one absolute low point once placed (see the comment
// above flat-stroke), and that shared low point is exactly up-stroke's own
// low: 0pt. Giving flat-stroke-bottom the same low: 0pt (with the line drawn
// at its local y: 0pt, i.e. right at that low point) puts its ink at that
// same absolute height, rather than rise-height/2 above it.
#let flat-stroke-bottom = (
  shape: line(start: (0pt, 0pt), end: (mark-length, 0pt), stroke: mark-stroke),
  low: 0pt,
  high: 0pt,
)

// `count` copies of `stroke`, side by side (one note each) -- for the
// "spaced" variants. All copies share one low/high (unchanged from a single
// stroke): laid out side by side rather than stacked, none of them sit any
// higher or lower than a single stroke would.
#let stroke-row(stroke, count: 1) = if count == 1 { stroke } else {
  (
    shape: stack(dir: ltr, spacing: mark-spaced-gap, ..range(count).map(_ => stroke.shape)),
    low: stroke.low,
    high: stroke.high,
  )
}

// `count` copies of `stroke`, stacked directly one above another -- for
// risetwo/risethree. Only the bottom-most copy's own low point and the
// top-most copy's own high point are the column's overall low/high; the
// bottom-most copy sits (count - 1) * mark-stack-gap below the column's
// origin (each copy above it contributes zero layout height of its own,
// per line()'s own sizing -- see mark-above below), so that offset carries
// straight through to its low point too.
#let stroke-column(stroke, count: 1) = if count == 1 { stroke } else {
  (
    shape: stack(dir: ttb, spacing: mark-stack-gap, ..range(count).map(_ => stroke.shape)),
    low: (count - 1) * mark-stack-gap + stroke.low,
    high: stroke.high,
  )
}

// A row of arbitrary, possibly mixed strokes (e.g. some up-stroke, some
// down-stroke), flush left instead of centred -- for spaced-left below.
// Unlike stroke-row above, mixed strokes don't already share one low/high:
// each is shifted by its own -low first, bringing every one of their low
// points to the row's own origin (0pt) before they're stacked side by
// side, so the strokes end up mutually aligned by their ink -- exactly the
// alignment mark-above gives strokes across different syllables, just
// applied within a single mark here.
#let stroke-row-mixed(strokes) = (
  shape: stack(dir: ltr, spacing: mark-spaced-gap, ..strokes.map(s => move(dy: -s.low, s.shape))),
  low: 0pt,
  high: calc.min(..strokes.map(s => s.high - s.low)),
)

// ---- overlay core -----------------------------------------------------------

// Place `stroke` above `body` without disturbing body's own position or
// baseline: body is the box's only flow content (so it keeps exactly the
// baseline it would have alone, held syllable or not -- see hold.typ's own
// comment for why that matters), and the stroke is a place() overlay
// floating in space the box's top inset reserves for it. The reserved
// height is `stroke.low - stroke.high` -- the stroke's own total ink span,
// not measured off the stroke itself: `measure()` reports a bare `line()`
// as zero-height regardless of slope (only start/end.x feed into it), so a
// diagonal up-/down-stroke would otherwise be treated as flat. The
// placement puts `stroke`'s own low point exactly mark-clearance.get()
// above body, so it (not the arbitrary local origin) is what ends up level
// with every other mark's low point. Pass `clearance:` to override that for
// a single mark (e.g. `rise(clearance: 5pt)[geest]`) without touching the
// shared mark-clearance state, so neighbouring marks are unaffected.
//
// Deliberately, `clearance` feeds only the place()'s dy, not the inset: the
// inset is what Typst charges against this line's height when it lays out
// the paragraph, while dy is a free-floating offset place() doesn't get
// charged for. Folding clearance into the inset too (as an earlier version
// did) reserved exactly enough box height that the ink never crossed the
// box's own top edge -- tidy, but it meant every bump to mark-clearance
// grew the box and pushed neighbouring lines apart. Leaving the inset fixed
// at `span` keeps line height constant no matter how large clearance gets;
// the mark instead bleeds upward past the box's own top edge (place()
// overlays aren't clipped to their container) into the ordinary whitespace
// between lines. That's exactly the room mark-clearance is meant to use --
// it's only a problem if it grows large enough to reach the line above,
// which is on whoever sets mark-clearance to watch for, the same way
// oversized ordinary text would be.
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
#let mark-above(stroke, body, align-mark: center, clearance: auto) = context {
  let clearance = if clearance == auto { mark-clearance.get() } else { clearance }
  let span = stroke.low - stroke.high
  let bw = measure(body).width
  let mw = measure(stroke.shape).width
  let w = calc.max(bw, mw)
  let dx = if align-mark == left { 0pt } else { (w - mw) / 2 }
  // Reset the text edges back to the font's own defaults for this syllable
  // (cap-height/baseline) -- but only when layout.typ's constant-line-height
  // reservation is on. That reservation enlarges the global top-/bottom-edge so
  // every plain line reserves a mark's and a hold's worth of space; here the
  // reservation comes from this box's own `inset: (top: span)` instead, so the
  // enlarged edge must not stack on top of it or the mark would drift upward. A
  // local `set` wins over layout.typ's blanket one. When a document opts out
  // (conf(reserve: false)), leave the syllable's edges alone so it inherits the
  // document's own top-edge -- see reserve-line-height in layout.typ.
  // Spread from a dict that is empty when reset is off, so the `set` governs
  // `body` -- a `set` written inside `if reset {}` would scope to the if-block
  // and never reach body.
  let reset = state("pitchmarks-reserve-line-height", true).get()
  let reset-edges = if reset { (top-edge: "cap-height", bottom-edge: "baseline") } else { (:) }
  box(width: w, inset: (top: span))[
    #{ set text(..reset-edges); body }
    #place(top, dx: dx, dy: -(clearance + stroke.low), stroke.shape)
  ]
}

// ---- pitch marks --------------------------------------------------------

// `clearance:` on every mark below overrides mark-clearance for that single
// call only -- see mark-above's own comment for why.
#let rise(body, clearance: auto) = mark-above(up-stroke, body, clearance: clearance)
#let risetwo(body, clearance: auto) = mark-above(stroke-column(up-stroke, count: 2), body, clearance: clearance)
#let risethree(body, clearance: auto) = mark-above(stroke-column(up-stroke, count: 3), body, clearance: clearance)

#let fall(body, clearance: auto) = mark-above(down-stroke, body, clearance: clearance)
#let falltwo(body, clearance: auto) = mark-above(stroke-column(down-stroke, count: 2), body, clearance: clearance)
#let fallthree(body, clearance: auto) = mark-above(stroke-column(down-stroke, count: 3), body, clearance: clearance)

// Several strokes over one syllable, each a separate note (side by side, not stacked).
#let risetwice(body, clearance: auto) = mark-above(stroke-row(up-stroke, count: 2), body, clearance: clearance)
#let falltwice(body, clearance: auto) = mark-above(stroke-row(down-stroke, count: 2), body, clearance: clearance)
#let fallthreespaced(body, clearance: auto) = mark-above(stroke-row(down-stroke, count: 3), body, clearance: clearance)

// Level (unchanging) pitch: a short flat bar over the syllable.
#let level(body, clearance: auto) = mark-above(flat-stroke, body, clearance: clearance)
// Same, but bottom-aligned with the diagonal strokes -- see flat-stroke-bottom.
#let level-bottom(body, clearance: auto) = mark-above(flat-stroke-bottom, body, clearance: clearance)

// A row of arbitrary strokes (mix up-stroke/down-stroke/flat-stroke), flush
// left over the syllable instead of centred -- for runs like "three falls
// then a rise" over one long syllable.
#let spaced-left(strokes, body, clearance: auto) = mark-above(stroke-row-mixed(strokes), body, align-mark: left, clearance: clearance)
#let spaced-center(strokes, body, clearance: auto) = mark-above(stroke-row-mixed(strokes), body, align-mark: center, clearance: clearance)
