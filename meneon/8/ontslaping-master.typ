// Master document: concatenates the Ontslaping antifoons/hymns into one PDF.
// Deliberately leaves out ontslaping3.typ.
//
// Each included file is self-contained -- it imports the shared modules and
// applies `#show: conf` itself, and its own `../../shared/...` imports resolve
// relative to that file -- so this master only has to pull them in, in order.
//
// Compile from the repo root so the shared `../../shared/...` imports don't
// escape Typst's project sandbox:
//
//   typst compile --root . meneon/8/ontslaping-master.typ meneon/8/ontslaping-master.pdf
//
// The pagebreaks keep each part starting on a fresh page (matching how they
// compile as standalone PDFs); remove them to let the parts flow together.

#include "ontslaping.typ"
#pagebreak()
#include "ontslaping2.typ"
#pagebreak()
#include "ontslaping4.typ"
#pagebreak()
#include "ontslaping5.typ"
