#import "svg-score.typ": svg-score, svg-pages

#set page(paper: "a4", margin: 1in, numbering: none)
#set text(font: "Helvetica")

// scoryst-free counterpart of songs/scoryst/unequal-fifths.typ.
#align(center, text(weight: "bold", size: 16pt)[Unequal Fifths])
#align(center, text(size: 11pt, style: "italic")[a diminished fifth beside a perfect fifth])
#v(14pt)

#let prefix = "/songs/musicxml-svg/unequal-fifths"
#for p in range(1, svg-pages(prefix) + 1) [
  #if p > 1 [ #pagebreak() ]
  #svg-score(prefix, page: p, width: 100%)
]

#v(18pt)

#set text(size: 10pt)
#block(width: 100%, [
  *What it is.* An _unequal fifth_ is a diminished fifth and a perfect fifth in
  succession between the same two voices, moving in similar motion. Because the
  two fifths are of different size it is not a true parallel fifth -- so whether
  it is allowed depends on the direction and on which voices are involved. All
  three examples here use the same tritone *B–F*.

  *The rules.*
  #list(
    [*P5 → d5* (example 1) is *always fine*: you leave a perfect consonance for a
     dissonant, diminished one, so there is no pair of perfect fifths to object to.],
    [*d5 → P5* (example 2) is the *restricted* case -- the "unequal fifths" proper.
     It is avoided between the *outer voices* (and in strict two-part writing),
     because the diminished fifth wants to resolve inward and letting it expand to
     a perfect fifth evades that, approaching a parallel-fifth effect. Between
     *inner* voices, though, it is freely tolerated -- Bach writes it often.],
    [*Best* (example 3): *resolve the diminished fifth inward*. B rises to C and F
     falls to E, so the tritone contracts to a third -- exactly the V#super[7] → I
     resolution (seventh down by step, leading tone up).],
  )
  Play *unequal-fifths.mid* to hear how naturally the third example settles.
])
