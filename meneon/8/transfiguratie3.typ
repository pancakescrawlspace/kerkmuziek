#import "../../shared/pitch-marks.typ": *  // rise/risetwo/risethree and fall/... : pitch marks; level: flat mark
#import "../../shared/hold.typ": *          // hold : underline a held syllable
#import "../../shared/finalskip.typ": *     // finalskip : space before the final line
#import "../../shared/layout.typ": *        // page setup, body font, paragraph spacing, headings

// This crop-to-fit variant sets its own top-edge and tunes mark clearances by
// hand, so it opts out of conf's constant-line-height reservation.
#show: conf.with(reserve: false)
#set page(width: auto, height: auto, margin: 6pt, fill: none)

#title[Tropaar van Transfiguratie (t.~7)]
#v(.5em)
#set text(top-edge: .5em)
#mark-clearance.update(6pt)
De ge#rise[#hold[daan]]#fall[te] #fall(clearance: 7pt)[U]wer heerlijkheid, o Chris#rise[tus] #rise[#hold[God]],

#mark-clearance.update(5pt)
hebt Gij op de berg aange#hold[no]#fall[#hold[men]],

om #rise(clearance: 6pt)[Uw] #fall[dis]#fall[ci]pelen Uw glorie te #spaced-left((flat-stroke-bottom, up-stroke),[to-])#rise[#hold[nen]],

#mark-clearance.update(4pt)
voorzover deze te aan#hold[schou]wen #fall[#hold[was]].

#mark-clearance.update(5pt)
Laat #rise[voor] #fall[ons] #fall[zon]daren Uw eeuwig licht ook #spaced-center((flat-stroke-bottom, up-stroke),[stra-])#rise[#hold[len]],

door de gebeden van de #hold[Moe]der #fall[#hold[Gods]],

Gij #rise[li]#fall[cht]#fall[#hold[schen]]ken#rise[de] #rise[#hold[Heer]],
#v(2pt)
#spaced-left((down-stroke, down-stroke, down-stroke), [e-~~~])#rise[re] zij #fall[#hold[U]]!