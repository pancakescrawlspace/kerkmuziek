#!/usr/bin/env python3
"""voice-explode-single-lyrics.py -- split a MusicXML score's multi-voice
parts into one part per voice, same as voice-explode.py, but *without*
propagating lyrics to voices that don't already have their own.

Standard choral-engraving practice prints the lyrics only once (typically
under the top voice) on the understanding that every voice sings the same
syllable at the same moment; a reader seeing all four staves together infers
the words apply throughout. This script preserves exactly that: a part like
<part-name>Soprano/Alto</part-name> carrying <voice>1</voice> (with lyrics)
and <voice>2</voice> (without) becomes two full parts, and Alto's part comes
out with no lyrics at all, same as in the source.

Use voice-explode.py instead if you want every exploded voice to carry its
own copy of the words (borrowed from whichever voice in the score has them at
that position) -- more useful once each voice is on its own staff/page and
the "the words are implied" convention no longer reads as obviously.

Everything else -- naming, ids, MIDI-channel eligibility for voice-mix.sh,
untouched single-voice parts -- is identical to voice-explode.py; see that
script's docstring for details. Both take the same CLI.

Usage:
    python3 tools/voice-explode-single-lyrics.py <input.musicxml> <output.musicxml>

Example:
    python3 tools/voice-explode-single-lyrics.py songs/musicxml/four-voices.musicxml /tmp/four-voices.exploded-single-lyrics.musicxml

Requires only the standard library.
"""
import re
import sys

VOICE_TAGGED_RE = re.compile(r"<(note|forward|direction)\b[^>]*>.*?</\1>", re.S)
VOICE_RE = re.compile(r"<voice>(\d+)</voice>")
BACKUP_RE = re.compile(r"<backup>.*?</backup>", re.S)
MEASURE_RE = re.compile(r"(<measure\b[^>]*>)(.*?)(</measure>)", re.S)
PART_RE = re.compile(r'<part id="([^"]+)">(.*?)</part>', re.S)
SCORE_PART_RE = re.compile(
    r'<score-part id="([^"]+)">\s*<part-name([^>]*)>([^<]*)</part-name>(.*?)</score-part>', re.S
)


def voices_used(part_body: str) -> list:
    return sorted({int(v) for v in VOICE_RE.findall(part_body)}) or [1]


def filter_for_voice(part_body: str, voice: int) -> str:
    """Keep only voice-tagged elements for `voice` (plus untagged, global
    ones); drop <backup> entirely -- a single voice needs no rewind."""

    def do_measure(m):
        open_tag, body, close_tag = m.group(1), m.group(2), m.group(3)
        body = BACKUP_RE.sub("", body)

        def keep(bm):
            block = bm.group(0)
            vm = VOICE_RE.search(block)
            return block if vm is None or int(vm.group(1)) == voice else ""

        return open_tag + VOICE_TAGGED_RE.sub(keep, body) + close_tag

    return MEASURE_RE.sub(do_measure, part_body)


def names_for(label: str, n: int) -> list:
    labels = [p.strip() for p in label.split("/")]
    if len(labels) == n and all(labels):
        return labels
    return [f"{label} (voice {v})" if label else f"Voice {v}" for v in range(1, n + 1)]


def explode(xml: str) -> str:
    score_parts = {sp[0]: sp for sp in SCORE_PART_RE.findall(xml)}
    new_score_parts, new_parts = {}, {}

    for part_id, body in PART_RE.findall(xml):
        voices = voices_used(body)
        if len(voices) == 1:
            continue  # already single-voice; leave verbatim

        _, name_attrs, label, _ = score_parts.get(part_id, (part_id, "", part_id, ""))
        names = names_for(label.strip(), len(voices))

        sp_blocks, p_blocks = [], []
        for name, voice in zip(names, voices):
            new_id = f"{part_id}-{voice}"
            sp_blocks.append(
                f'<score-part id="{new_id}">\n    '
                f"<part-name{name_attrs}>{name}</part-name>\n  </score-part>"
            )
            p_blocks.append(f'<part id="{new_id}">{filter_for_voice(body, voice)}</part>')

        new_score_parts[part_id] = "\n  ".join(sp_blocks)
        new_parts[part_id] = "\n  ".join(p_blocks)

    xml = re.sub(
        r'<score-part id="([^"]+)">\s*<part-name[^>]*>[^<]*</part-name>.*?</score-part>',
        lambda m: new_score_parts.get(m.group(1), m.group(0)),
        xml,
        flags=re.S,
    )
    xml = re.sub(
        r'<part id="([^"]+)">.*?</part>',
        lambda m: new_parts.get(m.group(1), m.group(0)),
        xml,
        flags=re.S,
    )
    return xml


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: voice-explode-single-lyrics.py <input.musicxml> <output.musicxml>")
    inp, outp = sys.argv[1:3]
    xml = open(inp).read()
    open(outp, "w").write(explode(xml))
    print(f"wrote {outp}")


if __name__ == "__main__":
    main()
