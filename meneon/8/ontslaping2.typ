#import "../../shared/pitch-marks.typ": *  // rise/risetwo/risethree and fall/... : pitch marks; level: flat mark
#import "../../shared/hold.typ": *          // hold : underline a held syllable
#import "../../shared/finalskip.typ": *     // finalskip : space before the final line
#import "../../shared/layout.typ": *        // page setup, body font, paragraph spacing, headings

#show: conf

#let vskip = 8pt

#heading-line[2#super[e] antifoon]
#v(8pt)

--- De Heer #rise[be]#rise[mint] de poor#fall[ten] #rise[van] #rise[#hold[Si]]#fall[#hold[on]],

#falltwo[bo]#rise[ven] #rise[al]le ten#fall[ten] #fall[van] #rise[#hold[Ja]]#fall[#hold[cob]].

#v(vskip)
#set par(first-line-indent: 20pt)

#mark-clearance.update(5pt) Ver#risetwo[los] #falltwo[ons] #mark-clearance.update(3pt) #rise[Zoon] van #fall[#hold[God]],

Die in #rise[Uw] #rise[#hold[Hei]]ligen wonder#fall[baar]#rise[lijk] #rise[#hold[zijt]],

#fall[laat] #rise[ons] #fall[U] #fall[be]#fall[zi]ngen: al#rise[le]#rise[#hold[lu]]#fall[#hold[-~~]]#fall[#hold[ja]].

#v(vskip)
#set par(first-line-indent: 0pt)

O#rise[ver] #rise[U] zijn roem#fall[rij]#rise[ke] #rise[#hold[din]]gen ge#fall[#hold[zegd]],

#mark-clearance.update(5pt) #falltwo[Gi]#mark-clearance.update(3pt)#rise[j] #rise[zijt] #falltwice[de] #rise[#hold[Stad]] van #fall[#hold[God]].
#v(vskip)
#set par(first-line-indent: 20pt)

#mark-clearance.update(5pt) Ver#risetwo[los] #falltwo[ons] #mark-clearance.update(3pt) #rise[Zoon] van #fall[#hold[God]]...

#v(vskip)
#set par(first-line-indent: 0pt)

God heeft haar #rise[ge]#rise[grond]#fall[vest] #rise[voor] #rise[#hold[eeu]]#fall[#hold[wig]]#text[;]

#mark-clearance.update(5pt) #falltwo[God],#mark-clearance.update(3pt) wij #rise[ver]#rise[wach]ten Uw barmhartigheid in het \ mid#fall[den] #fall[van] #rise[#hold[Uw]] #fall[#hold[volk]].

#v(vskip)
#set par(first-line-indent: 20pt)

#mark-clearance.update(5pt) Ver#risetwo[los] #falltwo[ons] #mark-clearance.update(3pt) #rise[Zoon] van #fall[#hold[God]]...

#v(vskip)
#set par(first-line-indent: 0pt)

#spaced-center((flat-stroke-bottom, up-stroke),[De]) #rise[Al]#spaced-center((down-stroke, up-stroke),[ler])#rise[#hold[hoog]]#fall[#hold[ste]],

hei#fall[ligt] #fall[Zijn] #rise[#hold[woon]]#fall[#hold[tent]].

#v(vskip)
#set par(first-line-indent: 20pt)

#mark-clearance.update(5pt) Ver#risetwo[los] #falltwo[ons] #mark-clearance.update(3pt) #rise[Zoon] van #fall[#hold[God]]...

#v(vskip)
#set par(first-line-indent: 0pt)

Eer aan #rise[de] #rise[Va]der, de Zoon #fall[en] #rise[de] #rise[#hold[Hei]]lige #fall[#hold[Geest]].

#h(1fr)#text(size:14pt, weight: 700)[#emph[(verder met "Eniggeboren Zoon")]]