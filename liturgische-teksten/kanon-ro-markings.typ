// Layout test: kanon-ro.typ reproduced exactly, with pitch marks added to
// one irmos only (Ode 8, "Pe Îmăratul ceresc..."), to judge how the shared
// pitch-mark and hold macros fit the kanon booklet layout. Compile from the
// repo root, since it imports ../shared:
//   typst compile --root . liturgische-teksten/kanon-ro-markings.typ
// Everything else below is unchanged from kanon-ro.typ, whose header
// explains the source of the text.

#import "../shared/pitch-marks.typ": *  // rise/risetwo/risethree and fall/... : pitch marks
#import "../shared/hold.typ": *          // hold : underline a held syllable

#set par(justify: true)
#set text(lang: "ro")

#set page(
  paper: "a5",
  numbering: "1",
  header: block(width: 100%)[
    #align(center, text(style: "italic", size: 11pt)[Paraclisul Preasfintei Născătoare de Dumnezeu])
    #v(-0.6em)
    #line(length: 100%)
  ],
)

#let subtitle(body) = {
  align(center, text(weight: "bold", size: 14pt, body))
}

// See kanon.typ for why this is an SVG image rather than a font glyph.
#let maltese-cross(size: 20pt) = image("maltese-cross.svg", width: size, height: size)

#page(numbering: none, header: none)[
  #set par(justify: false)
  #v(1fr)
  #align(center)[
    #text(weight: "bold", size: 22pt)[Paraclisul Preasfintei Născătoare de Dumnezeu]
    #v(1em - 3.15pt)
    #maltese-cross()
    #v(1em + 3.15pt) // nudge to visually center the cross between title and subtitle
    #text(style: "italic", size: 13pt)[Roemeense tekst van \ de Smeekcanon tot de Moeder Gods] // dummy subtitle
  ]
  #v(1fr)
  #align(center)[
    #text(size: 9pt)[
      Russisch-Orthodoxe Parochie \ van de Heilige Transfiguratie \ te Groningen#v(-3pt)
      #emph[2026]
    ] // dummy publisher information
  ]
  #v(3em)
]

#page(numbering: none, header: none)[]

#set text(size: 12pt)

#subtitle[Cântarea 1]

#text(weight: 700)[Irmosul:] Apa trecând-o ca pe uscat și din răutatea egiptenilor scăpând, israeliteanul striga: Izbăvitorului și Dumnezeului nostru să-I cântăm.

#text(weight: 700)[Stih:] Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

De multe ispite fiind cuprins, către tine alerg, căutând mântuire: O, Maică a Cuvântului și Fecioară, de rele și de nevoi mântuiește-mă.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Asupririle chinurilor mă tulbură și de multe întristări se umple sufletul meu; alină-le, Fecioară, cu liniștea Fiului și Dumnezeului tău, ceea ce ești cu totul fără de prihană.

-- Slavă Tatălui și Fiului și Sfântului Duh.

Pe tine, ceea ce ai născut pe Mântuitorul și Dumnezeu, te rog, Fecioară, izbăvește-mă din nevoi; că la tine scăpând acum îmi tind și sufletul și gândul meu.

-- Și acum și pururea și în vecii vecilor. Amin.

Fiind bolnav cu trupul și cu sufletul, cercetării celei dumnezeiești și purtării tale de grijă învrednicește-mă, Maica lui Dumnezeu, ca una ceea ce ești bună și Născătoarea Celui bun.

#subtitle[Cântarea a 3-a]

#text(weight: 700)[Irmosul:] Doamne, Cel ce ai făcut cele de deasupra crugului ceresc și ai zidit Biserica, Tu pe mine mă întărește întru dragostea Ta; că Tu ești marginea doririlor și credincioșilor întărire, Unule, Iubitorule de oameni.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Folositoare și acoperământ vieții mele te pun pe tine, Născătoare de Dumnezeu Fecioară; tu mă îndreptează la adăpostirea ta, ceea ce ești pricina bunătăților și credincioșilor întărire, una întru tot lăudată.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Rogu-mă, Fecioară, risipește tulburarea sufletului meu și viforul întristărilor mele; că tu, Mireasă dumnezeiască, pe Hristos începătorul liniștii L-ai născut, ceea ce ești una preacurată.

-- Slavă Tatălui și Fiului și Sfântului Duh.

Ceea ce ai născut pe Făcătorul de bine, Care este pricina bunătăților, bogăția facerii de bine izvorăște-o tuturor; că toate le poți, ca ceea ce ai născut pe Hristos cel puternic întru tărie, de Dumnezeu fericită.

-- Și acum și pururea și în vecii vecilor. Amin.

De neputințe cumplite și de chinuri de boală fiind cuprins, Fecioară, ajută-mi; că pe tine te știu comoară de tămăduiri neîmpuținată și necheltuită, ceea ce ești cu totul fără de prihană.

Izbăvește din nevoi pe robii tăi, Născătoare de Dumnezeu, că noi toți la tine scăpăm, după Dumnezeu, ca la un zid nestricat; fii folositoare.

Caută cu milostivire, cu totul lăudată Născătoare de Dumnezeu, spre necazul cel cumplit al trupului meu și vindecă durerea sufletului meu.

#subtitle[Tropar, glasul al 2-lea]

Ceea ce ești rugătoare caldă și zid nebiruit, izvor de milă și lumii scăpare, cu dinadinsul strigăm către tine, Născătoare de Dumnezeu: Stăpână, vino degrab și ne mântuiește din nevoi, ceea ce ești una grabnic folositoare.

#subtitle[Cântarea a 4-a]

#text(weight: 700)[Irmosul:] Am auzit, Doamne, taina rânduielii Tale, am înțeles lucrurile Tale și am preaslăvit Dumnezeirea Ta.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Tulburarea patimilor mele și viforul greșelilor mele alină-le, ceea ce ai născut pe Domnul îndreptătorul, dumnezeiască Mireasă.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Chemând eu adâncul milostivirii tale, dă-mi-l, ceea ce ai născut pe Cel milostiv și pe Mântuitorul tuturor celor ce te laudă pe tine.

-- Slavă Tatălui și Fiului și Sfântului Duh.

Îndulcindu-ne, Preacurată, de darurile tale, ție cântare de mulțumire cântăm, știindu-te pe tine Maica lui Dumnezeu.

-- Și acum și pururea și în vecii vecilor. Amin.

Nădejde și întărire și zid de scăpare nemișcat câștigându-te pe tine, ceea ce ești întru tot lăudată, de tot necazul ne mântuim.

#subtitle[Cântarea a 5-a]

#text(weight: 700)[Irmosul:] Luminează-ne pe noi, Doamne, cu poruncile Tale și cu brațul Tău cel înalt; pacea Ta dă-ne-o nouă, Iubitorule de oameni.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Umple, Preacurată, inima mea de veselie, dăruindu-mi bucuria ta cea nestricăcioasă, ceea ce ai născut pricina veseliei.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Mântuiește-ne din primejdii, Născătoare de Dumnezeu curată, ceea ce ai născut mântuirea cea veșnică și pacea care covârșește toată mintea.

-- Slavă Tatălui și Fiului și Sfântului Duh.

Risipește negura greșelilor mele, dumnezeiască Mireasă, cu strălucirea luminii tale, ceea ce ai născut lumina cea dumnezeiască și veșnică.

-- Și acum și pururea și în vecii vecilor. Amin.

Tămăduiește, Curată, neputința sufletului meu, învrednicindu-mă cercetării tale; și sănătate, cu rugăciunile tale, dăruiește-mi.

#subtitle[Cântarea a 6-a]

#text(weight: 700)[Irmosul:] Rugăciunea mea voi vărsa către Domnul și Lui voi spune necazurile mele; că s-a umplut sufletul meu de răutăți și viața mea s-a apropiat de iad, și ca Iona mă rog: Dumnezeule, din stricăciune scoate-mă!

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Cum a mântuit de moarte și de stricăciune firea mea, care era ținută de moarte și de stricăciune, Însuși pe Sine dându-Se spre moarte, Fecioară, roagă-te Fiului și Dumnezeului tău, să mă izbăvească și de răutățile vrăjmașilor.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Folositoare și păzitoare prea tare vieții mele te știu pe tine, Fecioară, care risipești tulburarea năpastelor și izgonești asupririle diavolilor; de aceea mă rog totdeauna: De stricăciunea chinurilor mele mântuiește-mă.

-- Slavă Tatălui și Fiului și Sfântului Duh.

Ca un zid de scăpare te-am câștigat pe tine, și sufletelor mântuire desăvârșită și ușurare întru necazuri, Fecioară, și de lumina ta pururea ne bucurăm, o, Stăpână! Și acum pe noi de chinuri și de nevoi mântuiește-ne.

-- Și acum și pururea și în vecii vecilor. Amin.

Acum zac în patul durerilor și nu este tămăduire trupului meu; ci mă rog ție, celei bune, care ai născut pe Dumnezeu, Mântuitorul lumii și tămăduitorul bolilor, ridică-mă din chinul durerilor.

#subtitle[Condac, glasul al 6-lea]

Ceea ce ești neînfruntată folositoare creștinilor și neschimbată mijlocitoare către Făcătorul, nu trece cu vederea glasurile de rugăciune ale păcătoșilor, ci sârguiește ca o bună, spre ajutorul nostru, care cu credință ne rugăm ție: Grăbește spre rugăciune și te nevoiește spre îmblânzire, apărând pururea pe cei ce te cinstesc pe tine, Născătoare de Dumnezeu.

#subtitle[Cântarea a 7-a]

#text(weight: 700)[Irmosul:] Tinerii cei ce au mers din Iudeea în Babilon oarecând, cu credința Treimii, văpaia cuptorului au călcat-o, cântând: Dumnezeul părinților noștri bine ești cuvântat!

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Când ai vrut, Mântuitorule, să plinești mântuirea noastră, în pântecele Fecioarei Te-ai sălășluit, pe care ai arătat-o lumii folositoare; Dumnezeul părinților noștri, bine ești cuvântat!

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Pe voitorul milei pe Care L-ai născut, Maică Preacurată, roagă-L să izbăvească de greșeli și de toată întinăciunea sufletească pe cei ce cântă cu credință: Dumnezeul părinților noștri, bine ești cuvântat!

-- Slavă Tatălui și Fiului și Sfântului Duh.

Comoară de mântuire și izvor de curăție, turn de tărie și ușă de pocăință, pe ceea ce Te-a născut pe Tine ai arătat-o celor ce cântă: Dumnezeul părinților noștri, bine ești cuvântat!

-- Și acum și pururea și în vecii vecilor. Amin.

De neputințele trupești și de păcatele sufletești, Născătoare de Dumnezeu, pe cei ce vin cu dragoste către acoperământul tău cel dumnezeiesc învrednicește-i să se tămăduiască, ceea ce ai născut nouă pe Mântuitorul Hristos.

#subtitle[Cântarea a 8-a]

// The marks are reconstructed from the psaltic (Byzantine neume) score as
// sung at Stavropoleos Monastery, Bucharest -- pp. 17-18 of
// https://www.stavropoleos.ro/wp-content/uploads/Psaltica/Rugaciuni/paraclis_primul.pdf
// (see SOURCES.md). The words therefore follow that score rather than the
// Râmnic text used everywhere else in this file: Stavropoleos sings
// "...Îl laudă îngereștile cete, cântați-L și preaînălțați-L, noroade,
// totdeauna" where Râmnic has "...Îl laudă oștile îngerești, lăudați-L și-L
// preaînălțați întru toți vecii".
//
// Neumes record steps, not absolute pitches, so each one maps directly onto
// a mark: ison (same note) gets no mark, as in makrina.typ; oligon,
// petasti and kentimata (+1) get rise; kentima (+2) risetwo; apostrophos
// (-1) fall; elaphron (-2) falltwo; chamili (-4) fallthree, the most strokes
// pitch-marks.typ has. A syllable carrying two notes gets two side-by-side
// strokes (risetwice/falltwice), and klasma or dipli (lengthen the note)
// get hold. Syllable by syllable, as read from the score:
//
//   Pe ison · Îm ison · pă apostrophos · ra oligon ·
//   -a oligon + kentimata below (two notes up) · -a oligon + antikenoma ·
//   tul apostrophos + klasma | martyria Ke
//   Ce elaphron · resc oligon · pe oligon · Ca oligon + yporroi (?) ·
//   re apostrophos · Îl apostrophos · la oligon · u ison ·
//   dă apostrophos + klasma
//   în ison · ge ison · reș petasti · ti apostrophos · le ison ·
//   ce chamili (?) · -e kentimata · te oligon + antikenoma ·
//   cân apostrophos · ta, ți-L apostrophos + klasma | martyria Ni
//   și oligon + kentima · prea ison · î oligon · năl oligon ·
//   ța yporroi (?) · ți-L, no apostrophos · roa oligon + yporroi (?) ·
//   de apostrophos · tot ison · dea elaphron · u oligon + klasma ·
//   na apostrophos + dipli | martyria Ga
//
// UNVERIFIED. Adding the steps up phrase by phrase should land on the red
// martyriae (pitch checkpoints) printed in the score. That works for the
// first phrase (Ga to Ke) but not for the later ones, so at least one neume
// marked (?) above is misread. The directions of the marks are more
// reliable than the number of strokes. A chanter should check this against
// the score before it is used.
#text(weight: 700)[Irmosul:] Pe Îm#fall[pă]#rise[ra]#risetwice[-a]#rise[-a]#fall[#hold[tul]] #falltwo(clearance: 0.25em)[Ce]#rise[resc], #rise[pe] #falltwice[Ca]#fall[re] #fall[Îl] #rise[la]u#fall[#hold[dă]] înge#rise[reș]#fall[ti]le #box[#fallthree(clearance: 0.4em)[ce]#rise[-e-]#rise[te]], #fall[cân]#fall[#hold[ta]]#fall[#hold[ți-L]] #risetwo(clearance: 0.25em)[și] prea#rise[î]#rise[năl]#falltwice[ța]#fall[ți-L], #fall[no]#falltwice[roa]#fall[de], tot#falltwo(clearance: 0.25em)[dea]#rise[#hold[u]]#fall[#hold[na]].

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Nu trece cu vederea, Fecioară, pe cei ce au nevoie de ajutorul tău, pe cei ce te laudă și te preaînalță întru toți vecii.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Tămăduiește neputințele sufletului și durerile trupului meu, Fecioară, ca să te slăvesc, curată, în veci.

-- Binecuvântăm pe Tatăl și pe Fiul și pe Sfântul Duh, Domnul.

Bogăție de tămăduiri reverși peste cei ce te laudă pe tine cu credință, Fecioară, și slăvesc nașterea ta cea negrăită.

-- Și acum și pururea și în vecii vecilor. Amin.

Tirania ispitelor și năvala patimilor tu le izgonești, Fecioară; pentru aceasta te lăudăm întru toți vecii.

#subtitle[Cântarea a 9-a]

#text(weight: 700)[Irmosul:] Cu adevărat, Născătoare de Dumnezeu, te mărturisim pe tine Fecioară curată, noi cei izbăviți prin tine, slăvindu-te cu cetele fără de trup.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Să nu-ți întorci de la izvorul lacrimilor mele, Fecioară, care ai născut pe Hristos, Cel ce a șters toată lacrima de pe fața tuturor.

-- Preasfântă Născătoare de Dumnezeu, miluiește-ne pe noi.

Umple de bucurie inima mea, Fecioară, ceea ce ai primit plinirea bucuriei și ai pierdut mâhnirea păcatului.

-- Slavă Tatălui și Fiului și Sfântului Duh.

Cu strălucirea luminii tale, Fecioară, luminează negura neștiinței și o izgonește de la cei ce cu credință te mărturisesc pe tine Născătoare de Dumnezeu.

-- Și acum și pururea și în vecii vecilor. Amin.

Pe mine, care zac de boală în locul cel de răutate, tămăduiește-mă, Fecioară, și mă întoarce dintru boală în sănătate.

#subtitle[Stihiri, glasul al 2-lea]

Pe cea mai înaltă decât cerurile și mai curată decât strălucirile soarelui, care ne-a mântuit pe noi din blestem, pe Stăpâna lumii cu cântări să o cinstim.

Pentru păcatele mele cele multe mi se îmbolnăvește trupul și slăbește sufletul meu; la tine scap, ceea ce ești plină de daruri; nădejdea tuturor celor fără de nădejde, tu îmi ajută.

Stăpâna mea și Maica Izbăvitorului, primește rugăciunile nevrednicilor robilor tăi, ca să fii mijlocitoare către Cel ce S-a născut din tine. O, Stăpâna lumii, fii mijlocitoare.

Cântăm acum cu osârdie cântare de bucurie ție, celei întru tot lăudată, Născătoare de Dumnezeu Fecioară: cu Înaintemergătorul și cu toți Sfinții roagă-L, Născătoare de Dumnezeu, să ne mântuiască pe noi.

Toate oștile îngerești, Înaintemergătorule al Domnului, cei doisprezece Apostoli și toți Sfinții, împreună cu Născătoarea de Dumnezeu faceți rugăciuni ca să ne mântuiască pe noi.
