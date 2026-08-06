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
  % Closing "Amen" (plagal cadence, IV-I), repeated a few bars over: sung
  % once, not per-verse -- see sopranoWordsOne/sopranoWordsTwo below for why
  % this stretch has only one lyrics line under it. Repeated far enough to
  % spill onto a new system, so the wrap can be checked too.
  c'2 c'2 | c'2 c'2 | c'2 c'2 | c'2 c'2 | c'2 c'2 |
  c'2 c'2 | c'2 c'2 | c'2 c'2 | c'2 c'2 | c'2 c'2 |
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
  a2 g2 | a2 g2 | a2 g2 | a2 g2 | a2 g2 |
  a2 g2 | a2 g2 | a2 g2 | a2 g2 | a2 g2 |
}

tenorMusic = {
  \voiceOne
  f4 f c' c' | d' d' c'2 |
  b4 b a a | g g f2 |
  c'4 c' b b | a a g2 |
  c'4 c' b b | a a g2 |
  f4 f c' c' | d' d' c'2 |
  b4 b a a | g g f2 |
  f2 e2 | f2 e2 | f2 e2 | f2 e2 | f2 e2 |
  f2 e2 | f2 e2 | f2 e2 | f2 e2 | f2 e2 |
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
  f,2 c,2 | f,2 c,2 | f,2 c,2 | f,2 c,2 | f,2 c,2 |
  f,2 c,2 | f,2 c,2 | f,2 c,2 | f,2 c,2 | f,2 c,2 |
}

sopranoWordsOne = \lyricmode {
  \set stanza = "1."
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
  Up a -- bove the world so high,
  Like a dia -- mond in the sky.
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
  A -- men. A -- men. A -- men. A -- men. A -- men.
  A -- men. A -- men. A -- men. A -- men. A -- men.
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
  % Deliberately no "Amen" entry here: \lyricsto just stops assigning
  % syllables once a lyric line runs out, so the final bar's notes get no
  % verse-2 text -- exactly the "one lyrics line only" bar this was added
  % to demonstrate.
}

\paper {
  #(define fonts
    (set-global-fonts
     #:roman "Helvetica"
     #:sans "Helvetica"
     #:typewriter "Helvetica"
    ))
  % Default indent still reserves first-system space for an instrument
  % name even with none set; zero it so the first system isn't indented
  % relative to the rest.
  indent = 0
}

\score {
  \new ChoirStaff <<
    \new Staff = "upper" <<
      \clef treble
      \key c \major
      \time 4/4
      \new Voice = "soprano" { \sopranoMusic }
      \new Voice = "alto" { \altoMusic }
    >>
    \new Lyrics \lyricsto "soprano" { \sopranoWordsOne }
    \new Lyrics \lyricsto "soprano" { \sopranoWordsTwo }
    \new Staff = "lower" <<
      \clef bass
      \key c \major
      \time 4/4
      \new Voice = "tenor" { \tenorMusic }
      \new Voice = "bass" { \bassMusic }
    >>
  >>
  \layout { }
  \midi { }
}
