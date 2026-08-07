\version "2.24.4"

% Shrink the page to the content's own bounding box (with a small built-in
% margin) instead of a full A4 sheet that's mostly blank. 'print-pages #f
% suppresses the separate full-page PDF that 'crop would otherwise still
% produce alongside the cropped one. Output is written as
% twinkle-twinkle.cropped.pdf (LilyPond always adds that suffix in crop
% mode) plus a .cropped.png preview -- rename/copy the .pdf to
% twinkle-twinkle.pdf after compiling to keep this repo's one-name.pdf-per-
% one-name.ly convention.
#(ly:set-option 'crop #t)
#(ly:set-option 'print-pages #f)

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

wordsOne = \lyricmode {
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
  Up a -- bove the world so high,
  Like a dia -- mond in the sky.
  Twin -- kle, twin -- kle, lit -- tle star,
  How I won -- der what you are!
}

wordsTwo = \lyricmode {
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
    \new Lyrics \lyricsto "melody" { \wordsOne }
    \new Lyrics \lyricsto "melody" { \wordsTwo }
  >>
  \layout { }
}
