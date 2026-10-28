// English counterpart of kanon.typ: same selection of texts and same
// layout, with the text of the Antiochian Orthodox Christian Archdiocese
// of North America's Little Paraklesis:
// https://antiochianprodsa.blob.core.windows.net/liturgicalinstructions/Paraklesis%20Little%20SERVICE.pdf
// The asterisks are the source's own: they mark the melodic phrases of each
// ode's heirmos, which its troparia are sung to phrase by phrase. They are
// escaped (\*) because a bare * is strong-emphasis markup in Typst, and
// tied to the preceding word (~) so that no line starts with one.

#set par(justify: true)
#set text(lang: "en")

#set page(
  paper: "a5",
  numbering: "1",
  header: block(width: 100%)[
    #align(center, text(style: "italic", size: 11pt)[Little Supplicatory Canon to the Most Holy Theotokos])
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
    #text(weight: "bold", size: 22pt)[Little Supplicatory Canon to the Most Holy Theotokos]
    #v(1em - 3.15pt)
    #maltese-cross()
    #v(1em + 3.15pt) // nudge to visually center the cross between title and subtitle
    #text(style: "italic", size: 13pt)[Engelse tekst van \ de Smeekcanon tot de Moeder Gods] // dummy subtitle
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

#subtitle[Ode One]

#text(weight: 700)[Heirmos:] Traversing the water as on dry land,~\* and thereby escaping~\* from the toils of Egypt’s land,~\* the Israelites cried aloud, proclaiming:~\* unto our God and Redeemer, let us now sing.

#text(weight: 700)[Refrain:] Most Holy Theotokos, save us!

By many temptations am I distressed;~\* in search of salvation~\* unto thee have I taken flight.~\* O Mother of the Word and Ever-virgin,~\* from all ordeals and afflictions deliver me.

-- Most Holy Theotokos, save us!

Attacks of the passions disquiet me;~\* my soul to repletion~\* has been filled with despondency.~\* Bestill them, O Maiden, with the calmness~\* of thine own Son and thy God, O All-blameless One.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

To Christ God, the Savior, thou gavest birth.~\* I beg thee, O Virgin,~\* from afflictions deliver me.~\* For now unto thee I flee for refuge,~\* bringing to thee both my soul and my reasoning.

-- Both now and ever, and unto ages of ages. Amen.

Diseased is my body and my soul.~\* Do thou make me worthy~\* of divine guidance and thy care,~\* O thou who alone art God’s Mother,~\* for thou art good, and the Birth-giver of the Good.

#subtitle[Ode Three]

#text(weight: 700)[Heirmos:] Of the vault of the heavens art Thou, O Lord, Fashioner;~\* so, too, of the Church art Thou Founder.~\* Do Thou establish me~\* in unfeigned love for Thee,~\* Who art the Height of things sought for,~\* and staff of the faithful, O Thou only Friend of man.

-- Most Holy Theotokos, save us!

I have thee as the shelter and the defense of my life.~\* Thee, the Theotokos and Virgin; pilot and govern me~\* into thy sheltered port,~\* for thou art author of good things~\* and staff of the faithful, O thou only lauded one.

-- Most Holy Theotokos, save us!

I beseech thee, O Virgin, do thou dispel far from me~\* all of the distress of despair and turbulence in my soul;~\* for thou, O Bride of God,~\* hast given birth to the Lord Christ,~\* Who is Prince of Peace, O thou only all-blameless one.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

Since thou gavest birth unto our Benefactor, the cause of good,~\* from the wealth of thy loving kindness, do thou pour forth on all;~\* for thou canst do all things,~\* since thou didst bear Christ, the One Who~\* is mighty in power; for blessed of God art thou.

-- Both now and ever, and unto ages of ages. Amen.

With most grievous diseases and with corrupt passions, too,~\* I am put to trial, O Virgin; come thou unto mine aid;~\* for I know thee to be~\* an inexhaustible treasure~\* of unfailing healing, O only all-blameless one.

Preserve and save, O Theotokos, thy servants from every danger. After God, do all of us for refuge flee unto thee; a firm rampart art thou and our protection.

In thy goodwill, look thou on me, O all-hymned Theotokos, and do thou behold my body’s grievous infirmity, and heal thou the cause of my soul’s sorrow.

#subtitle[Kathisma in Tone Two]

O fervent advocate, invincible battlement, fountain of mercy, and sheltering retreat for the world, earnestly we cry to thee: Lady Mother of God, hasten thou, and save us from all imperilment, for thou alone art our speedy protectress.

#subtitle[Ode Four]

#text(weight: 700)[Heirmos:] I have hearkened and heard, O Lord,~\* of Thy dispensation’s most awesome mystery;~\* and I came to knowledge of Thy works,~\* and I sang the praise of Thy Divinity.

-- Most Holy Theotokos, save us!

Lull the tempest of all my sins,~\* and bestill the raging of passions with thy calm;~\* for progenitress art thou of Him~\* Who is Lord and Helmsman, O thou Bride of God.

-- Most Holy Theotokos, save us!

O bestow out of the abyss~\* of thy great compassion on me thy supplicant;~\* for thou brought forth One compassionate~\* Who is Savior of all who sing hymns to thee.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

While delighting, O spotless one,~\* in thy many favors, a hymn of thankfulness~\* do we all raise up in song to thee,~\* knowing thee to be the Mother of our God.

-- Both now and ever, and unto ages of ages. Amen.

Having thee as our staff and hope,~\* and as our salvation’s unshaken battlement,~\* from all manner of adversity~\* are we then redeemed, O thou all-lauded one.

#subtitle[Ode Five]

#text(weight: 700)[Heirmos:] Lord, enlighten us~\* by Thy precepts and by Thy commands;~\* and by the power of Thy lofty arm~\* bestow Thy peace upon us all, since Thou art Friend of man.

-- Most Holy Theotokos, save us!

Pure one, fill my heart~\* with rejoicing unto plenitude,~\* and grant thine undefiled felicity,~\* since thou didst give birth unto Him Who is the cause of joy.

-- Most Holy Theotokos, save us!

Come, deliver us~\* out of dangers, O pure Mother of God,~\* since thou art Mother of deliverance,~\* and of the peace which doth surpass all human reasoning.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

Dissipate the gloom~\* of my trespasses, O Bride of God,~\* with the clear brightness of thy radiance,~\* for thou didst bear the Light divine which was before all time.

-- Both now and ever, and unto ages of ages. Amen.

Heal me, O pure one,~\* of the sickness which the passions bring,~\* and make me worthy of thy guardiancy,~\* and by thy prayers and intercessions grant thou health to me.

#subtitle[Ode Six]

#text(weight: 700)[Heirmos:] Entreaty do I pour forth unto the Lord,~\* and to Him do I proclaim all my sorrows,~\* for many woes fill my soul to repletion,~\* and lo, my life unto Hades hath now drawn nigh.~\* Like Jonah do I pray to Thee:~\* Raise me up from corruption, O Lord, my God.

-- Most Holy Theotokos, save us!

My nature, held by corruption and by death,~\* hath He saved from out of death and corruption,~\* for unto death He, Himself, hath submitted.~\* Wherefore, O Virgin, do thou intercede with Him~\* Who is in truth thy Lord and Son~\* to redeem me from enemies’ wickedness.

-- Most Holy Theotokos, save us!

I know thee as the protection of my life~\* and most safe fortification, O Virgin.~\* Disperse the horde of my many temptations~\* and put to silence demonic audacity.~\* Unceasingly I pray to thee:~\* From corruption of passions deliver me.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

A bulwark of safe retreat art thou to us,~\* and of souls art thou the perfect salvation,~\* and a relief in distresses, O Maiden;~\* and in thy light do we ever exult with joy.~\* O Lady, do thou also now~\* from all passions and perils deliver us.

-- Both now and ever, and unto ages of ages. Amen.

Bedridden, I lie supine with sickness now,~\* and no healing for my flesh is existent~\* except for thee, who didst bear the world’s Savior,~\* our God, the Healer of every infirmity.~\* I pray to thee, for thou art good:~\* From corruption of illnesses raise me up.

#subtitle[Kontakion in Tone Two]

O protection of Christians that cannot be put to shame, mediation unto the Creator most constant, O despise not the suppliant voices of those who have sinned; but be thou quick, O good one, to come unto our aid, who in faith cry unto thee: Hasten to intercession, and speed thou to make supplication, thou who dost ever protect, O Theotokos, them that honor thee.

#subtitle[Ode Seven]

#text(weight: 700)[Heirmos:] Once from out of Judea~\* did the children go down to the land of Babylon.~\* The fire of the furnace~\* they trampled down, while chanting~\* by their faith in the Trinity:~\* O God of our Fathers, blessed art Thou.

-- Most Holy Theotokos, save us!

Having willed thus, O Savior,~\* to dispense our salvation in Thine economy,~\* Thou dweltest in the Maid’s womb,~\* and unto all creation~\* as protectress didst show her forth.~\* O God of our Fathers, blessed art Thou.

-- Most Holy Theotokos, save us!

Make request, O pure Mother,~\* to thy Son Who hath willed to grant mercy unto us,~\* to rescue from transgressions~\* and from the soul’s defilement~\* those who cry out most faithfully:~\* O God of our Fathers, blessed art Thou.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

A fount of incorruption~\* and a tower of safety is she who gave Thee birth.~\* A treasure of salvation~\* and portal of repentance~\* hast Thou proved her to them that shout:~\* O God of our Fathers, blessed art Thou.

-- Both now and ever, and unto ages of ages. Amen.

Deign to grant restoration~\* from diseases of body and soul to those who run~\* to thy divine protection~\* with faith, O Theotokos,~\* and thus grant them recovery;~\* for Mother of Christ our Savior art thou.

#subtitle[Ode Eight]

#text(weight: 700)[Heirmos:] The King of Heaven,~\* Whom all the hosts of angels hymn~\* with their chants and praises of glory,~\* praise ye and exalt Him to the ages forever.

-- Most Holy Theotokos, save us!

Do not disdain those~\* who seek the aid that thou dost grant,~\* for, O Virgin Maiden, they do hymn thee,~\* and they all exalt thee unto ages forever.

-- Most Holy Theotokos, save us!

On all who hymn thee~\* with faith, O Virgin, and exalt~\* thy truly ineffable Offspring,~\* thou poured forth a great abundance of thy cures and healings.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

All the diseases~\* that plague my soul dost thou make well,~\* and the suff’rings of the flesh thou healest also;~\* wherefore, O thou Maiden full of grace, I glorify thee.

-- Both now and ever, and unto ages of ages. Amen.

All the assaultings~\* of the temptations dost thou quell,~\* and the onslaughts of the passions dost thou banish;~\* wherefore do we hymn thee to all ages, O Virgin.

#subtitle[Ode Nine]

#text(weight: 700)[Heirmos:] Most rightly we confess thee~\* as our God’s birthgiver,~\* we who through thee have been saved, O thou Virgin most pure.~\* With choirs of bodiless angels,~\* thee do we magnify.

-- Most Holy Theotokos, save us!

The torrent of my weeping~\* spurn not with refusal,~\* for thou didst give birth to Him Who doth take away all tears~\* from every face, O thou Virgin,~\* for He is Christ indeed.

-- Most Holy Theotokos, save us!

Do thou, O Virgin Maiden,~\* fill my heart with gladness,~\* for thou art she who received all the fullness of joy~\* and made to vanish away all~\* sorrow of sinfulness.

-- Most Holy Theotokos, save us!

A haven and protection,~\* and a wall unshaken,~\* and a rejoicing and shelter and place of retreat~\* do thou become, O thou Virgin,~\* for those who flee to thee.

-- Glory to the Father, and to the Son, and to the Holy Spirit.

Illumine with the radiance~\* of thy light, O Virgin,~\* all those who piously call thee the Mother of God;~\* and do thou banish away all~\* darkness of ignorance.

-- Both now and ever, and unto ages of ages. Amen.

Brought low am I, O Virgin,~\* in a place of sickness~\* and in a dwelling of anguish. Grant healing to me,~\* transforming all of my illness~\* into full healthfulness.

#subtitle[Megalynaria in Tone Eight]

Higher than the heavens above art thou,~\* and thou art much purer~\* than the radiance of the sun;~\* for thou hast redeemed us~\* out of the curse that held us.~\* O Mistress of creation,~\* with hymns we honor thee.

From the great abundance of all my sins,~\* ill am I in body,~\* ailing also am I in soul.~\* Thee have I as refuge.~\* Do thou therefore help me,~\* O hope of all the hopeless,~\* for thou art full of grace.

O Lady and Mother of Christ our God,~\* receive supplication~\* from us wretches, who beg of thee~\* that thou make entreaty~\* unto the One born from thee.~\* O Mistress of creation,~\* do thou intercede for us.

Now we chant with eagerness unto thee~\* with this ode most joyful,~\* O all-hymned Mother of our God.~\* Together with the Baptist~\* and all the saintly choirs,~\* beseech, O Theotokos,~\* that we find clemency.

O all ye arrays of angelic hosts,~\* with the Holy Baptist,~\* the Apostles’ twelve-numbered band,~\* all the Saints together,~\* as well as God’s birthgiver,~\* pray make ye intercession~\* for our deliverance.
