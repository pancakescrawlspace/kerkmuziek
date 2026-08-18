#set par(justify: true)

#set page(
  paper: "a5",
  numbering: "1",
  header: block(width: 100%)[
    #align(center, text(style: "italic", size: 10pt)[Канон молебный ко Пресвятой Богородице])
    #v(-0.6em)
    #line(length: 100%)
  ],
)

#let subtitle(body) = {
  align(center, text(weight: "bold", size: 14pt, body))
}

#page(numbering: none, header: none)[
  #set par(justify: false)
  #v(1fr)
  #align(center)[
    #text(weight: "bold", size: 22pt)[Канон молебный ко Пресвятой Богородице]
    #v(1em + 1.5pt)
    #text(font: "Zapf Dingbats", size: 28pt)[✠]
    #v(1em - 1.5pt) // nudge to visually center the cross between title and subtitle
    #text(style: "italic", size: 13pt)[Kerkslavische tekst van \ de Smeekcanon tot de Moeder Gods] // dummy subtitle
  ]
  #v(1fr)
  #align(center)[
    #text(size: 9pt)[
      Russisch-Orthodoxe Parochie \ van de Heilige Transfiguratie \ te Groningen#v(-3pt)
      2026
    ] // dummy publisher information
  ]
  #v(3em)
]

#set text(size: 12pt)

#subtitle[Пе́снь 1]

#text(weight: 700)[Ирмо́с:] Во́ду проше́д я́ко су́шу, и еги́петскаго зла́ избежа́в, изра́ильтянин вопия́ше: Изба́вителю и Бо́гу на́шему пои́м.

#text(weight: 700)[Припе́в:] Пресвята́я Богоро́дице, спаси́ на́с.

Мно́гими содержи́мь напа́стьми, к Тебе́ прибега́ю, спасе́ния иски́й: о Ма́ти Сло́ва и Де́во, от тя́жких и лю́тых мя́ спаси́.

Пресвята́я Богоро́дице, спаси́ на́с.

Страсте́й мя́ смуща́ют прило́зи, мно́гаго уны́ния испо́лнити мою́ ду́шу; умири́, Отрокови́це, тишино́ю Сы́на и Бо́га Твоего́, Всенепоро́чная.

Сла́ва Отцу, и Сы́ну, и Свято́му Ду́ху.

Спа́са ро́ждшую Тя́ и Бо́га, молю́, Де́во, изба́витися ми́ лю́тых; к Тебе́ бо ны́не прибега́я, простира́ю и ду́шу и помышле́ние.

И ны́не, и при́сно, и во ве́ки веко́в, ами́нь.

Неду́гующа те́лом и душе́ю, посеще́ния Боже́ственнаго и промышле́ния от Тебе́ сподо́би, еди́на Богома́ти, я́ко блага́я, Блага́го же Роди́тельница.

#subtitle[Пе́снь 3]

#text(weight: 700)[Ирмо́с:] Небе́снаго кру́га Верхотво́рче Го́споди, и Це́ркве Зижди́телю, Ты́ мене́ утверди́ в любви́ Твое́й, жела́ний кра́ю, ве́рных утвержде́ние, еди́не Человеколю́бче.