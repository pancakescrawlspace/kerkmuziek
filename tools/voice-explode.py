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

Lyrics: choral scores conventionally print the words only once (typically
under the top voice), since every voice sings the same syllable at the same
moment. Once split onto separate staves that's no longer implicit, so any
note being exploded that has no <lyric> of its own borrows one from whichever
voice/part in the score *does* have lyrics at that same position (same
measure, same cumulative offset since the start of the measure) -- a note
that already carries its own lyric is left alone.

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

ELEMENT_RE = re.compile(
    r"<note\b[^>]*>.*?</note>"
    r"|<backup>.*?</backup>"
    r"|<forward>.*?</forward>"
    r"|<direction\b[^>]*>.*?</direction>",
    re.S,
)
VOICE_RE = re.compile(r"<voice>(\d+)</voice>")
DURATION_RE = re.compile(r"<duration>(\d+)</duration>")
LYRIC_RE = re.compile(r"<lyric\b[^>]*>.*?</lyric>", re.S)
CHORD_RE = re.compile(r"<chord\s*/>")
MEASURE_RE = re.compile(r'(<measure\b[^>]*\bnumber="([^"]+)"[^>]*>)(.*?)(</measure>)', re.S)
PART_RE = re.compile(r'<part id="([^"]+)">(.*?)</part>', re.S)
SCORE_PART_RE = re.compile(
    r'<score-part id="([^"]+)">\s*<part-name([^>]*)>([^<]*)</part-name>(.*?)</score-part>', re.S
)


def voices_used(part_body: str) -> list:
    return sorted({int(v) for v in VOICE_RE.findall(part_body)}) or [1]


def _element_kind(text: str) -> str:
    if text.startswith("<backup"):
        return "backup"
    if text.startswith("<forward"):
        return "forward"
    if text.startswith("<direction"):
        return "direction"
    return "note"


def collect_lyrics(xml: str) -> dict:
    """Map (measure_number, offset) -> lyric XML, from the first note found
    bearing lyrics at that position, scanning every part/voice in the score.
    `offset` is the cumulative duration since the start of the measure, so
    positions line up across voices/parts sharing the same beat."""
    lyrics = {}
    for _, part_body in PART_RE.findall(xml):
        for _, num, body, _ in MEASURE_RE.findall(part_body):
            offset = 0
            for el in ELEMENT_RE.finditer(body):
                text = el.group(0)
                kind = _element_kind(text)
                if kind == "backup":
                    offset -= int(DURATION_RE.search(text).group(1))
                elif kind == "forward":
                    offset += int(DURATION_RE.search(text).group(1))
                elif kind == "note":
                    key = (num, offset)
                    if key not in lyrics:
                        found = LYRIC_RE.findall(text)
                        if found:
                            lyrics[key] = "".join(found)
                    if not CHORD_RE.search(text):
                        dm = DURATION_RE.search(text)
                        if dm:
                            offset += int(dm.group(1))
    return lyrics


def filter_for_voice(part_body: str, voice: int, lyrics: dict) -> str:
    """Keep only `voice`'s notes (plus untagged, global elements); drop
    <backup> entirely -- a single voice needs no rewind. Notes with no lyric
    of their own borrow one from `lyrics` at the same (measure, offset)."""

    def do_measure(m):
        open_tag, num, body, close_tag = m.group(1), m.group(2), m.group(3), m.group(4)
        offset = 0

        def repl(el):
            nonlocal offset
            text = el.group(0)
            kind = _element_kind(text)

            if kind == "backup":
                offset -= int(DURATION_RE.search(text).group(1))
                return ""
            if kind == "forward":
                dur = int(DURATION_RE.search(text).group(1))
                vm = VOICE_RE.search(text)
                keep = vm is None or int(vm.group(1)) == voice
                offset += dur
                return text if keep else ""
            if kind == "direction":
                vm = VOICE_RE.search(text)
                return text if vm is None or int(vm.group(1)) == voice else ""

            # note
            vm = VOICE_RE.search(text)
            v = int(vm.group(1)) if vm else 1
            note_offset = offset
            if not CHORD_RE.search(text):
                dm = DURATION_RE.search(text)
                if dm:
                    offset += int(dm.group(1))
            if v != voice:
                return ""
            if not LYRIC_RE.search(text):
                borrowed = lyrics.get((num, note_offset))
                if borrowed:
                    text = text[: -len("</note>")] + borrowed + "</note>"
            return text

        return open_tag + ELEMENT_RE.sub(repl, body) + close_tag

    return MEASURE_RE.sub(do_measure, part_body)


def names_for(label: str, n: int) -> list:
    labels = [p.strip() for p in label.split("/")]
    if len(labels) == n and all(labels):
        return labels
    return [f"{label} (voice {v})" if label else f"Voice {v}" for v in range(1, n + 1)]


def explode(xml: str) -> str:
    lyrics = collect_lyrics(xml)
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
            p_blocks.append(f'<part id="{new_id}">{filter_for_voice(body, voice, lyrics)}</part>')

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
