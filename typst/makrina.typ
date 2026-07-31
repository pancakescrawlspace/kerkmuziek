// Verheerlijkt -- a hymn typeset with pitch marks above the syllables.
// The typographic machinery lives in separate files, each covering one device
// (mirrors the pitch-marks.tex / hold.tex / finalskip.tex / layout.tex split
// of the TeX version this is a Typst port of):
#import "pitch-marks.typ": *  // rise/risetwo/risethree and fall/... : pitch marks; level: flat mark
#import "hold.typ": *          // hold : underline a held syllable
#import "finalskip.typ": *     // finalskip : space before the final line
#import "layout.typ": *        // page setup, body font, paragraph spacing, headings

#show: conf

#heading-line[Gedachtenis van de heilige Moeder Makrina]
#date-line[19 juli]
#v(8pt)

#title[Tropaar (t. 3)]
#falltwo[---] De liefde tot #rise[de] #rise[wijs]heid heeft vleugels geschon#fall[ken] #rise[aan] #risetwice[uw] #level[#hold[geest]],

en in die wijsheid hebt gij de vreugden der wereld ge#fall[#hold-wide[ri]]#fall[ng] #fall[ge]#fall[#hold[acht]].

Daardoor zijt gij #rise[een] #rise[vreug]devol verblijf der godde#fall[lij]#rise[ke] #risetwice[lief]#level[#hold[de]],

want door uw askese en #rise[#hold[hei]]#level[#hold[lig]]#fall[#hold[heid]]

zijt gij een Bruid geworden van uw #rise[Ver]#rise[#hold[los]]#fall[#hold[ser]],

tot Wie gij bidt voor ons die tot u #rise[#hold[roe]]#fall[#hold[pen]]:

#finalskip
Verheug u, Goddragen#fall[de] #fall[Ma]#spaced-left((down-stroke, down-stroke, down-stroke, up-stroke), [kri-])#rise[#hold[na]]! ---

#title[Kondak (t. 2)]
#rise[---] Geheel ver#rise[#hold[vuld]] van het licht der #rise[Ge]#rise[#hold[rech]]#fall[#hold[tig]]#fall[#hold[heid]],

zijt gij een voorbeeld geworden van Godwelgevallig #fall[#hold[le]]#fall[#hold[ven]],

#rise[en] een #rise[#hold[leids]]vrouw tot al#rise[le] #rise[#hold[deug]]#fall[#hold[den]]

voor hen die in geloof tot u #fall[#hold[roe]]#fall[#hold[pen]]:

#rise[Ver]#rise[#hold[heug]] u, #rise[Ma]#rise[#hold[kri]]#fall[#hold[na]],

#finalskip
die de stra#fall[len]#rise[de] #rise[#hold[schoon]]#fall[heid] #rise[der] #fall[#hold[maag]]#fall[#hold[den]] #fall[#hold[zijt]]. ---
