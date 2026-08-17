#!/usr/bin/env python3
"""voice-explode-music21.py -- like voice-explode.py, but using music21's
Score.voicesToParts() instead of hand-written regex/XML surgery. Built to
compare the two approaches on real scores (see tools/README.md).

Same idea as voice-explode.py: split parts carrying multiple <voice>-tagged
lines on one staff into one part per voice. Where voice-explode.py is regex
text surgery scoped to exactly the constructs this project's scores use, this
route re-parses the score into music21's object model and lets an
established library do the split -- it should generalize to MusicXML shapes
voice-explode.py's regexes don't handle (chords, <forward> padding,
cross-measure ties, multi-staff parts, ...), at the cost of being a much
heavier dependency, producing a larger/reformatted file (expanded whitespace,
<divisions> inflated to music21's internal PPQ, part ids replaced with opaque
hashes on write -- part.id is not honored, only partName is), and rewriting
every part it touches -- unlike voice-explode.py, even already-single-voice
parts get reformatted rather than left byte-identical.

Naming: mirrors voice-explode.py -- a part-name that splits into as many
"/"-separated labels as it has voices (e.g. "Soprano/Alto") gets those labels
assigned to the corresponding exploded parts; otherwise each becomes
"<original name> (voice N)".

Usage:
    python3 tools/voice-explode-music21.py <input.musicxml> <output.musicxml>

Example:
    python3 tools/voice-explode-music21.py songs/musicxml/four-voices.musicxml /tmp/four-voices.exploded-m21.musicxml

Requires the `music21` package (`pip install music21`).
"""
import re
import sys
import music21

VOICE_SUFFIX_RE = re.compile(r"^(.*)-v(\d+)$")


def name_for(label: str, voice_count: int, index: int) -> str:
    labels = [p.strip() for p in label.split("/")] if label else []
    if len(labels) == voice_count and all(labels):
        return labels[index]
    return f"{label} (voice {index + 1})" if label else f"Voice {index + 1}"


def explode(inp: str, outp: str) -> None:
    score = music21.converter.parse(inp)
    exploded = score.voicesToParts()

    # voicesToParts() suffixes every part id with "-v<index>" (0-based, in
    # original voice order), even for parts that had only one voice -- that
    # tells us both the original label and how many siblings it has.
    labels = [VOICE_SUFFIX_RE.match(p.id).group(1) for p in exploded.parts]
    voice_count = {label: labels.count(label) for label in set(labels)}

    seen = {}
    for part, label in zip(exploded.parts, labels):
        index = seen.get(label, 0)
        seen[label] = index + 1
        part.partName = name_for(label, voice_count[label], index)

    exploded.write("musicxml", fp=outp)


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: voice-explode-music21.py <input.musicxml> <output.musicxml>")
    inp, outp = sys.argv[1:3]
    explode(inp, outp)
    print(f"wrote {outp}")


if __name__ == "__main__":
    main()
