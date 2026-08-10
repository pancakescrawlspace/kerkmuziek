#import "@preview/scoryst:0.1.3": score

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// A three-voice fugal exposition on the subject of "Twinkle, Twinkle, Little
// Star" (its first four bars). The notes live in twinkle-fugue.musicxml, an
// open score (one voice per bracketed staff). As elsewhere, the title is drawn
// here in Typst rather than encoded as a <work-title> in the MusicXML.
#align(center, text(weight: "bold", size: 16pt)[Fugue à 3])
#align(center, text(size: 11pt, style: "italic")[on "Twinkle, Twinkle, Little Star"])
#v(14pt)

#score(
  read("twinkle-fugue.musicxml"),
  width: 100%,
)
