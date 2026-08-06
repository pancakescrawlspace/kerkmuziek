#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)

// "Twinkle, Twinkle, Little Star" arranged for SATB, split across the usual
// two staves (Soprano+Alto on treble, Tenor+Bass on bass). This is a simple
// demo harmonization (parallel diatonic thirds in the inner voices, root-motion
// bass), not a transcription of a published arrangement.
//
// Written as MusicXML rather than ABC: scoryst's bundled Verovio build does
// not support multi-voice ABC input (it warns "Multi-voice music is not
// supported" and collapses every V: line onto its own single-voice treble
// staff), but MusicXML's native multi-staff/multi-voice model renders
// correctly.
//
// Encoded as two separate <part>s (Soprano/Alto, Tenor/Bass) joined by a
// braced <part-group>, rather than one <part> with <staves>2</staves>:
// Verovio renders a single multi-staff part as a piano-style grand staff,
// with barlines running continuously through the lyrics area between the
// staves. Two parts grouped by a brace get the choir-style barline break
// between staves instead -- <group-barline>no</group-barline> makes this
// explicit rather than relying on the (undocumented, and untested here)
// default for an omitted group-barline. Splitting into two parts made
// Verovio print each part's <part-name> as a system label; suppressed with
// print-object="no" on <part-name> (keeps the identifying text for
// tooling, just doesn't render it).
#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, simple demo harmonization])
#v(12pt)

#score(
  read("four-voices.musicxml"),
  options: (header: "none", adjust-page-width: true),
  width: 100%,
)
