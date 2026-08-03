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
#let hang-indent = 1.5em      // wrapped (non-first) lines of a paragraph are indented this much

#let conf(body) = {
  set page(paper: "a4", margin: 1in, numbering: none)
  set text(font: body-font, size: body-size)
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
// spacing (sized for the pitch marks) that follows.
#let title(body) = {
  v(10pt)
  align(center, text(weight: "bold", size: 16pt, body))
  v(5pt)
}

#let heading-line(body) = align(center, text(weight: "bold", size: 21pt, body))
#let date-line(body) = {
  v(3pt)
  align(center, text(size: 14pt, body))
}
