// Generates an 8-page A5 PDF with a large page number on each page, for
// physically testing which `flip` mode (long/short) impose.typ needs for
// your printer. See ../README.md for the test procedure.
//
// Usage:
//   typst compile print/test-pages.typ print/test-pages.pdf

#set page(paper: "a5", margin: 0pt)

#for n in range(1, 9) {
  page(align(center + horizon, text(size: 60pt)[#n]))
}
