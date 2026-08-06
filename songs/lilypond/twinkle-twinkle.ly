\version "2.24.4"

\header {
  title = "Twinkle, Twinkle, Little Star"
  tagline = ##f
}

melody = {
  \clef treble
  \key c \major
  \time 4/4
  c''4 c'' g'' g'' | a'' a'' g''2 |
  f''4 f'' e'' e'' | d'' d'' c''2 |
  g''4 g'' f'' f'' | e'' e'' d''2 |
  g''4 g'' f'' f'' | e'' e'' d''2 |
  c''4 c'' g'' g'' | a'' a'' g''2 |
  f''4 f'' e'' e'' | d'' d'' c''2 |
  \bar "|."
}

words = \lyricmode {
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
  Up a -- bove the world so high,
  Like a dia -- mond in the sky.
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
}

\score {
  \new Staff <<
    \new Voice = "melody" { \melody }
    \new Lyrics \lyricsto "melody" { \words }
  >>
  \layout { }
}
