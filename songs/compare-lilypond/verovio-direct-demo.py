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

Deliberately does NOT set adjustPageHeight/adjustPageWidth (unlike
tools/musicxml2svg.py, which wants each page cropped tightly to its own
content for embedding as a Typst image) -- those make Verovio crop every
page to a different size driven by how much content happens to be on it,
which is exactly wrong for a real PDF: rsvg-convert would need a fixed
--page-width/--page-height to make the pages uniform, but the content
itself (rendered at its natural, uncropped size) is usually bigger than
that page, so it would just get cut off rather than actually fitting.
Leaving those options unset uses Verovio's own default page size --
pageWidth/pageHeight default to 2100/2970, which are already A4 (210mm x
297mm) -- so Verovio does real pagination (line/page breaks as needed)
onto a fixed, uniform page instead, which is what you want out of a PDF.

Verovio's SVG width/height are in its own drawing units, 10 per mm (so
the "2100px" a Verovio SVG for an A4 page declares means 210mm, not 2100
CSS pixels at the usual 96dpi) -- rsvg-convert doesn't know that
convention, so it must be told to render at 254dpi (25.4mm/inch * 10
units/mm) for those units to come out as their true physical size; at
the default 96dpi the same SVG renders about 2.6x too large and the
"A4" page comes out as ~1575x2227pt instead of the true 595x842pt.

Usage:
    python3 verovio-direct-demo.py <input.musicxml> <output.pdf>

Requires: the `verovio` Python package, plus `rsvg-convert` (librsvg) and
`pdfunite` (poppler) on PATH.
"""
import sys
import subprocess
import shutil
import tempfile
import pathlib
import verovio


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: verovio-direct-demo.py <input.musicxml> <output.pdf>")
    inp, outp = sys.argv[1], sys.argv[2]

    tk = verovio.toolkit()
    tk.setOptions({
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
                [
                    "rsvg-convert",
                    "-f", "pdf",
                    "-d", "254", "-p", "254",  # see the module docstring
                    "-o", str(pdf_path),
                    str(svg_path),
                ],
                check=True,
            )
            pdf_pages.append(str(pdf_path))

        if len(pdf_pages) == 1:
            # shutil.move, not Path.rename: the tmp dir and outp can be on
            # different filesystems (e.g. running in a container with outp
            # on a bind-mounted volume), and plain rename(2) can't cross
            # that boundary -- shutil.move falls back to copy+delete there.
            shutil.move(pdf_pages[0], outp)
        else:
            subprocess.run(["pdfunite", *pdf_pages, outp], check=True)

    print(f"wrote {outp}")


if __name__ == "__main__":
    main()
