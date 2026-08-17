#!/usr/bin/env python3
"""voice-explode.py -- split a MusicXML score's multi-voice parts into one
part per voice, so each voice becomes independently addressable.

A part like <part-name>Soprano/Alto</part-name> carrying <voice>1</voice> and
<voice>2</voice> notes on one staff becomes two full parts, one per voice --
nothing is muted or dropped, the notation is unchanged, it's just regrouped.
Single-voice parts are left untouched.

This is what lets voice-mix.sh set an independent volume per voice later:
Verovio assigns each <part> its own MIDI channel on export, but does not
split channels within a part by voice, so a per-voice channel requires a
per-voice part first.

Naming: if a part's <part-name> splits into as many "/"-separated labels as
it has voices (e.g. "Soprano/Alto" -> voice 1 = Soprano, voice 2 = Alto),
those labels are used for the new parts; otherwise each becomes
"<original name> (voice N)". New part/score-part ids are "<original id>-N".

Usage:
    python3 tools/voice-explode.py <input.musicxml> <output.musicxml>

Example:
    python3 tools/voice-explode.py songs/musicxml/four-voices.musicxml /tmp/four-voices.exploded.musicxml

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
        sys.exit("usage: voice-explode.py <input.musicxml> <output.musicxml>")
    inp, outp = sys.argv[1:3]
    xml = open(inp).read()
    open(outp, "w").write(explode(xml))
    print(f"wrote {outp}")


if __name__ == "__main__":
    main()
