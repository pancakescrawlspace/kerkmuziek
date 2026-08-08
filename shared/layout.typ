// Document layout: page size/margins, body font, paragraph spacing and
// hanging indent, plus a couple of heading helpers. Ties together with
// pitch-marks.typ and hold.typ only in that it picks a font size to match
// (the mark/hold dimensions there are plain point values, not derived from
// the font the way the TeX version's \riseheight etc. were).
//
// `conf` is a Typst "template" function: apply it to the whole document
// with `#show: conf` (see makrina.typ). #set rules written directly in this
// module would stay local to it -- they don't leak into an importing file
// just by importing -- so page/text/par setup has to be wrapped in a
// function like this and threaded through explicitly.

#let body-font = "Helvetica"
#let body-size = 18pt
#let body-font-weight = 400
// Helvetica only has Regular (400) and Bold (700) faces -- no weight in
// between actually exists, so asking Typst for e.g. 500 or 525 just snaps to
// whichever of those two is numerically closer (Regular, in that case) with
// no visible change. This stroke, drawn on top of the Regular glyph fill, is
// what actually makes the text a little bolder without jumping all the way
// to Bold or switching to a different family/letterforms (Helvetica Neue's
// Medium was tried and looked too heavy).
#let body-font-stroke = 0.18pt + black
#let hang-indent = 20pt      // wrapped (non-first) lines of a paragraph are indented this much

// Pitch marks and holds set line height by reserving space in their own
// inline box: a mark's box has `inset: (top: span)` above the syllable, a
// hold's has `inset: (bottom: ...)` below it (see mark-above in
// pitch-marks.typ and hold-below in hold.typ). A line that happens to carry
// neither reserves nothing, so its box is only as tall as the bare text and
// it sits noticeably tighter against its neighbours than every marked/held
// line does -- the line-height unevenness this document had.
//
// The fix, applied in `conf` below: give *plain* text the same reservation on
// every line via text's top-/bottom-edge, so the line box is a constant height
// whether or not marks or holds land on it. This is a blanket `set`, so it
// also reaches text that has nothing to do with pitch marks -- the mark/hold
// boxes' own syllables, headings, the spoken intro. Each of those undoes it
// with `..default-edges` (below), which restores the font's own metrics and
// its natural, tighter line height. A local `set` wins over this blanket one,
// so the reservation on those elements then comes only from their own box
// inset (marks/holds, placement unchanged) or is simply absent (headings,
// prose). Note it must be a plain `set`, not a `show text` rule: a reset via
// `show text: set text(...)` only applies partially (top-edge but not
// bottom-edge), landing between enlarged and default -- see git history.
//
// default-edges names Typst's actual defaults, verified by measuring a
// multi-line block: "cap-height"/"baseline" reproduces it exactly, whereas
// "ascender"/"descender" overshoots (taller than default). cap-height at
// body-size measures 12.91pt, so a plain line reserves 12.91 + 3.5 above.
#let default-edges = (top-edge: "cap-height", bottom-edge: "baseline")
#let text-cap-height = 12.91pt        // Helvetica body-size, baseline -> cap-height (the default top edge)
#let mark-reserve = 3.5pt             // = rise-height in pitch-marks.typ
#let hold-reserve = 3.5pt             // = hold-clearance + hold-thickness in hold.typ

// Prose that is not sung -- the spoken intro before a hymn -- should keep the
// font's natural line height, not the mark/hold reservation. Wrap it in this.
#let spoken(body) = { set text(..default-edges); body }

// Whether the constant-line-height reservation (below) is active. mark-above
// and hold-below read this same state to decide whether to reset their
// syllable's edges. Documents that manage line height themselves -- setting
// their own top-edge and tuning mark clearances by hand, like the crop-to-fit
// transfiguratie3/4/5 -- opt out with `#show: conf.with(reserve: false)`,
// which both skips the edge enlargement here and tells the marks/holds not to
// reset, so they inherit the document's own edges exactly as before.
#let reserve-line-height = state("pitchmarks-reserve-line-height", true)

#let conf(body, reserve: true) = {
  set page(paper: "a4", margin: 1in, numbering: none)
  set text(font: body-font, size: body-size, weight: body-font-weight, stroke: body-font-stroke)
  reserve-line-height.update(reserve)
  // Reserve, on every line, the same room a mark reserves above and a hold
  // reserves below -- so an unmarked/unheld line is exactly as tall as one
  // carrying both, and line spacing no longer depends on which marks fall
  // where. top-edge/bottom-edge are lengths from the baseline; the default
  // (cap-height/baseline, see note above) measures 12.91pt and 0pt here.
  // Non-hymn text opts back out with `..default-edges` (headings, `spoken`).
  // Spread the edges from a dict that is empty when `reserve` is false, so the
  // one `set` still governs `body` (a `set` nested in an `if {}` would scope to
  // the if-block instead).
  set text(..(if reserve { (top-edge: text-cap-height + mark-reserve, bottom-edge: -hold-reserve) } else { (:) }))
  // 6pt is the smallest gap that clears a pitch mark on one line from a
  // descender (g, j, ...) on the line above -- found by shrinking it until
  // the tallest mark used (falltwo) just touched a "gg jjj" test line, then
  // adding a little back. Not proportional to body-size like a typical
  // em-based leading would be: the marks' own dimensions in pitch-marks.typ
  // are fixed point values, not relative to text size, so this is tied to
  // body-size only through this file's specific choice of it, and would
  // need rechecking (by the same shrink-until-it-touches process) if either
  // changed.
  set par(leading: 6pt, spacing: 6pt, first-line-indent: 0pt, hanging-indent: hang-indent, justify: false)
  body
}

// A hymn heading: bold, centered, with a little air above and below --
// separating it from whatever came before, and from the hymn's own line
// spacing (sized for the pitch marks) that follows. Headings carry no marks,
// so `..default-edges` opts them out of conf's blanket line-height reservation
// back to the font's natural metrics; they get their air from the v()s around
// them. (These edges reproduce the default for a block of running text but not
// exactly for a short bold heading line, so in a reserve:false document with
// several headings they drift a hair -- harmless.)
#let title(body) = {
  v(10pt)
  align(center, text(weight: "bold", size: 16pt, ..default-edges, body))
  v(5pt)
}

#let subtitle(body) = {
  v(5pt)
  align(center, text(weight: "bold", size: 14pt, ..default-edges, body))
  v(3pt)
}
#let heading-line(body) = align(center, text(weight: "bold", size: 21pt, ..default-edges, body))
#let date-line(body) = {
  v(3pt)
  align(center, text(size: 14pt, ..default-edges, body))
}
