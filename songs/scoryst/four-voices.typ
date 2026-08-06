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
#align(center, text(weight: "bold", size: 16pt)[Twinkle, Twinkle, Little Star])
#align(center, text(size: 10pt, style: "italic")[SATB, simple demo harmonization])
#v(12pt)

#score(
  read("four-voices.musicxml"),
  options: (header: "none", adjust-page-width: true),
  width: 100%,
)
