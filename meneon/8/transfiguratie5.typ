#import "../../shared/pitch-marks.typ": *  // rise/risetwo/risethree and fall/... : pitch marks; level: flat mark
#import "../../shared/hold.typ": *          // hold : underline a held syllable
#import "../../shared/finalskip.typ": *     // finalskip : space before the final line
#import "../../shared/layout.typ": *        // page setup, body font, paragraph spacing, headings

// This crop-to-fit variant sets its own top-edge and tunes mark clearances by
// hand, so it opts out of conf's constant-line-height reservation.
#show: conf.with(reserve: false)
#set page(width: auto, height: auto, margin: 6pt, fill: none)

#title[Kondak van Transfiguratie (t.~7)]
#v(.5em)
Ver#rise[#hold[heer]]#fall[lijkt] #fall[werd] Gij op de berg, o Chris#rise[tus] #rise[#hold[God]],

en Uw discipelen aanschouwden Uw glorie \ voorzover zij dit #hold[kon]#fall(clearance: 3pt)[#hold[den]],

op#rise[dat], #fall[wan]#fall[neer] zij U gekruisigd zou#rise[den] #rise[#hold[zien]],

zij zouden beseffen dat Uw lijden vrij#hold[wil]lig #fall(clearance: 3pt)[#hold[was]],

en #rise[aan] #fall[de] #fall[we]reld zouden verkon#rise[di]#rise[#hold[gen]]

#v(2pt)
dat Gij waarlijk  de #fall[#hold[af]]glans #fall[van] #fall[de] #rise[#hold[Va]]#hold[der] #fall[#hold[zijt]].
