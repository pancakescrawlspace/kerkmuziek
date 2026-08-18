// Imposes an already-compiled A5 PDF (e.g. kanon.pdf) two-up onto A4
// sheets for duplex printing and cutting, so that after cutting each
// physical A4 sheet in half, consecutive document pages (1&2, 3&4, ...)
// end up front and back on the same A5 leaf.
//
// Run from the liturgische-teksten/ directory (the --root is needed
// because this file lives in a subdirectory but reads ../kanon.pdf):
//   typst compile --root . print/impose.typ print/kanon-for-print.pdf
//   typst compile --root . --input flip=short print/impose.typ print/kanon-for-print.pdf
//
// `flip` controls how the back side is paired, to compensate for how
// your printer's duplex unit mirrors the sheet. Try "long" first; if the
// cut sheets come out with the wrong pages back-to-back, use "short"
// instead. See ../README.md for the physical test to determine which one
// is correct for your printer — the mapping from "long edge"/"short edge"
// in a print dialog to this mirroring is printer/driver-specific and not
// safe to assume.

#let source = sys.inputs.at("source", default: "../kanon.pdf")
#let total-pages = int(sys.inputs.at("pages", default: "3")) // update whenever kanon.pdf's page count changes
#let flip = sys.inputs.at("flip", default: "long")

#let padded = calc.ceil(total-pages / 4) * 4

#let page-image(n) = if n <= total-pages {
  image(source, page: n, width: 100%, height: 100%)
} else {
  []
}

#set page(paper: "a4", flipped: true, margin: 0pt)

#for k in range(0, padded, step: 4) {
  let (a, b, c, d) = (k + 1, k + 2, k + 3, k + 4)
  let (left-back, right-back) = if flip == "long" { (d, b) } else { (b, d) }

  grid(columns: (1fr, 1fr), page-image(a), page-image(c))
  pagebreak(weak: true)
  grid(columns: (1fr, 1fr), page-image(left-back), page-image(right-back))
  if k + 4 < padded { pagebreak(weak: true) }
}
