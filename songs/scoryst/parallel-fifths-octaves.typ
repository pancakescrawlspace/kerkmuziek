#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// A demo of parallel fifths and parallel octaves: why classical part-writing
// avoids them. Two voices on one staff; the number under each beat is the
// interval between them. Each faulty example is followed by a corrected one.
// The notes live in ../musicxml/parallel-fifths-octaves.musicxml; play the sibling .mid to
// hear how the parallel perfects make the two voices fuse into a single line.
#align(center, text(weight: "bold", size: 16pt)[Parallel Fifths & Octaves])
#align(center, text(size: 11pt, style: "italic")[why they are avoided in part-writing])
#v(14pt)

// The MusicXML carries <print new-system="yes"/> marks (one example per system);
// a renderer that honours encoded breaks will lay it out that way. scoryst 0.1.3
// cannot request them -- it int-encodes Verovio's `breaks` option, which Verovio
// only accepts as a string -- so here the labels are kept short enough that the
// automatic layout does not collide.
#score(
  read("../musicxml/parallel-fifths-octaves.musicxml"),
  width: 100%,
)

#v(18pt)

#set text(size: 10pt)
#block(width: 100%, [
  *What to listen for.* In the faulty examples both voices move in the same
  direction while holding a perfect fifth (or octave). A perfect fifth/octave
  blends so completely that the two voices stop sounding independent and merge
  into one thickened line -- the very independence that two-voice writing exists
  to create is lost. The corrected examples keep the same upper line but harmonise
  it with thirds and sixths (imperfect consonances) and some contrary motion, so
  the two voices stay audibly distinct. Play *parallel-fifths-octaves.mid* to
  hear the difference.
])
