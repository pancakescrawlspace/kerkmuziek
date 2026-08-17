#!/usr/bin/env python3
"""verovio-direct-demo.py -- render a MusicXML score straight to PDF via
Verovio's Python bindings, with no scoryst / Typst / WASM involved: Verovio
renders each page to SVG, librsvg's rsvg-convert turns each into a one-page
PDF, poppler's pdfunite stitches them into the final multi-page PDF.

This is what scoryst's score() call does internally (Verovio -> SVG,
embedded via Typst's image()) minus the Typst layer -- useful to see
exactly what's being wrapped, and to control pagination directly: this
loops over every Verovio page itself, rather than scoryst's score()
defaulting to page 1 only (the bug fixed in songs/scoryst/*.typ a few
turns back).

Usage:
    python3 verovio-direct-demo.py <input.musicxml> <output.pdf>

Requires: the `verovio` Python package, plus `rsvg-convert` (librsvg) and
`pdfunite` (poppler) on PATH.
"""
import sys
import subprocess
import tempfile
import pathlib
import verovio


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: verovio-direct-demo.py <input.musicxml> <output.pdf>")
    inp, outp = sys.argv[1], sys.argv[2]

    tk = verovio.toolkit()
    tk.setOptions({
        "adjustPageHeight": True,
        "adjustPageWidth": True,
        "header": "none",
        "inputFrom": "auto",
    })
    if not tk.loadFile(inp):
        sys.exit(f"verovio failed to load {inp}")

    n_pages = tk.getPageCount()
    print(f"{n_pages} page(s)")

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp = pathlib.Path(tmp_dir)
        pdf_pages = []
        for i in range(1, n_pages + 1):
            svg_path = tmp / f"page{i}.svg"
            pdf_path = tmp / f"page{i}.pdf"
            svg_path.write_text(tk.renderToSVG(i))
            subprocess.run(
                ["rsvg-convert", "-f", "pdf", "-o", str(pdf_path), str(svg_path)],
                check=True,
            )
            pdf_pages.append(str(pdf_path))

        if len(pdf_pages) == 1:
            pathlib.Path(pdf_pages[0]).rename(outp)
        else:
            subprocess.run(["pdfunite", *pdf_pages, outp], check=True)

    print(f"wrote {outp}")


if __name__ == "__main__":
    main()
