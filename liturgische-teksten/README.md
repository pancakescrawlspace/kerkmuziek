# Printing kanon.pdf as an A5 booklet

`kanon.typ` is set at A5 page size. To print it two-up on A4 and cut the
sheets in half, the page order needs to be pre-arranged — otherwise the
front/back pairing comes out wrong after cutting.

## The problem

Naively printing two A5 pages per A4 sheet with duplex, in plain document
order, produces mismatched pairs after cutting: the back of page 1 ends up
being page 4, and the back of page 2 ends up being page 3 (instead of 1↔2
and 3↔4 as intended). This happens because duplex printing **mirrors**
the sheet when it's flipped over.

This is a prepress problem called **imposition** — specifically the
"cut-and-stack" variant (consecutive pairs stay together as front/back of
one leaf), as opposed to the more commonly-tooled "saddle-stitch/booklet"
imposition (pages nested in wraparound order for folding a signature).
Since the reordering only ever operates on groups of 4 consecutive pages
(one A4 sheet = 4 A5 slots), it doesn't depend on the total page count —
only on padding the count up to a multiple of 4.

## The tool: `print/impose.typ`

A pure-Typst script (no TeX/pdfjam — Typst can embed pages of an existing
PDF directly via `image("file.pdf", page: n)`). Run from
`liturgische-teksten/`:

```sh
typst compile --root . print/impose.typ print/kanon-for-print.pdf
```

This reads `kanon.pdf`, arranges its pages 2-up on landscape A4 sheets in
the correct cut-and-stack order, and pads with a blank page if the page
count isn't a multiple of 4.

**Before running for real**, open `print/impose.typ` and update
`total-pages` to match the current page count of `kanon.pdf` (easiest way
to check: open kanon.pdf in any PDF viewer, which shows the page count).

### Choosing the flip mode

The `flip` setting ("long" or "short") controls how the back side is
paired, to compensate for how your printer's duplex unit mirrors the
sheet when flipped. **Which one is correct depends on your printer/driver
and can't be predicted reliably** — the mapping from a print dialog's
"long edge"/"short edge" binding setting to actual left-right vs
top-bottom mirroring depends on how the driver handles the interaction
between the physical paper orientation and our landscape 2-up content,
and reasoning it out either way is genuinely error-prone (double-checking
this while writing the tool produced contradictory answers).

Default is `flip=long`; override on the command line:

```sh
typst compile --root . --input flip=short print/impose.typ print/kanon-for-print.pdf
```

### Verifying which mode is correct

A cheap physical test, using the included 8-page numbered test document:

```sh
typst compile print/test-pages.typ print/test-pages.pdf
typst compile --root . --input source=test-pages.pdf --input pages=8 print/impose.typ print/test-long.pdf
typst compile --root . --input source=test-pages.pdf --input pages=8 --input flip=short print/impose.typ print/test-short.pdf
```

Print `test-long.pdf` duplex with your normal print settings, cut the
sheet(s) in half, and check: does the leaf showing "1" on the front show
"2" on the back (not "4")? If yes, use `flip=long` for the real document.
If the pairing is wrong, try `test-short.pdf` instead — one of the two
should match. (`test-pages.pdf` and the `test-*.pdf` outputs are
regeneratable build artifacts, not committed.)

## Status

Tooling is built and mechanically verified (correct page selection,
ordering, and padding, checked by rendering each output side). Not yet
verified against a real printer — do the physical test above before
printing the whole book.
