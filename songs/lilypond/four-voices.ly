\version "2.24.4"

% Same "Twinkle, Twinkle, Little Star" SATB harmonization as
% songs/scoryst/four-voices.typ and songs/typed-scores/four-voices.typ
% (parallel diatonic thirds in the inner voices, root-motion bass) --
% written a third time here so all three packages can be compared on
% an identical piece.

\header {
  title = "Twinkle, Twinkle, Little Star"
  subtitle = "SATB, simple demo harmonization"
  tagline = ##f
}

sopranoMusic = {
  \voiceOne
  c'4 c' g' g' | a' a' g'2 |
  f'4 f' e' e' | d' d' c'2 |
  g'4 g' f' f' | e' e' d'2 |
  g'4 g' f' f' | e' e' d'2 |
  c'4 c' g' g' | a' a' g'2 |
  f'4 f' e' e' | d' d' c'2 |
  \bar "|."
}

altoMusic = {
  \voiceTwo
  a4 a e' e' | f' f' e'2 |
  d'4 d' c' c' | b b a2 |
  e'4 e' d' d' | c' c' b2 |
  e'4 e' d' d' | c' c' b2 |
  a4 a e' e' | f' f' e'2 |
  d'4 d' c' c' | b b a2 |
}

tenorMusic = {
  \voiceOne
  f4 f c' c' | d' d' c'2 |
  b4 b a a | g g f2 |
  c'4 c' b b | a a g2 |
  c'4 c' b b | a a g2 |
  f4 f c' c' | d' d' c'2 |
  b4 b a a | g g f2 |
  \bar "|."
}

bassMusic = {
  \voiceTwo
  c,4 c, g, g, | a, a, g,2 |
  f,4 f, c, c, | g, g, c,2 |
  g,4 g, f, f, | c, c, g,2 |
  g,4 g, f, f, | c, c, g,2 |
  c,4 c, g, g, | a, a, g,2 |
  f,4 f, c, c, | g, g, c,2 |
}

sopranoWordsOne = \lyricmode {
  \set stanza = "1."
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
  Up a -- bove the world so high,
  Like a dia -- mond in the sky.
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
}

% Second verse: same note-per-syllable shape as the first (four lines, the
% first two repeated at the end), so it drops onto the same 12 bars with no
% change to the music -- this is the traditional second verse of Jane
% Taylor's poem, sung to the same repeating tune as the first.
sopranoWordsTwo = \lyricmode {
  \set stanza = "2."
  When the blaz -- ing sun is gone,
  When he noth -- ing shines up -- on,
  Then you show your lit -- tle light,
  Twin -- kle, twin -- kle, all the night.
  When the blaz -- ing sun is gone,
  When he noth -- ing shines up -- on,
}

\score {
  \new ChoirStaff <<
    \new Staff = "upper" \with {
      instrumentName = "Soprano / Alto"
      shortInstrumentName = "S / A"
    } <<
      \clef treble
      \key c \major
      \time 4/4
      \new Voice = "soprano" { \sopranoMusic }
      \new Voice = "alto" { \altoMusic }
    >>
    \new Lyrics \lyricsto "soprano" { \sopranoWordsOne }
    \new Lyrics \lyricsto "soprano" { \sopranoWordsTwo }
    \new Staff = "lower" \with {
      instrumentName = "Tenor / Bass"
      shortInstrumentName = "T / B"
    } <<
      \clef bass
      \key c \major
      \time 4/4
      \new Voice = "tenor" { \tenorMusic }
      \new Voice = "bass" { \bassMusic }
    >>
  >>
  \layout { }
}
