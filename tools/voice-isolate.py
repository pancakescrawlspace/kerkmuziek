#!/usr/bin/env python3
"""voice-isolate.py -- isolate one voice of a MusicXML score by turning every
other voice's notes into same-duration rests, so the exported MIDI/MP3 plays
only that line (and a rendered PDF shows only that line's noteheads).

Built for scores like four-voices.musicxml, where each part carries two (or
more) voices sharing a staff (<part-name>Soprano/Alto</part-name>, notes
tagged <voice>1</voice>/<voice>2</voice>). It rewrites a *copy* of the
MusicXML (the file on disk is untouched): notes outside the target part+voice
keep their duration/voice but lose pitch, stem, and lyrics, becoming rests.

Usage:
    python3 tools/voice-isolate.py <input.musicxml> <output.musicxml> <voice>

<voice> is either a part-name label from the score (e.g. Soprano, Alto,
Tenor, Bass -- matched case-insensitively against each part's
"Name1/Name2/..." <part-name>) or an explicit "<part-id>:<voice-number>"
like P1:1.

Examples:
    python3 tools/voice-isolate.py songs/musicxml/four-voices.musicxml /tmp/soprano.musicxml soprano
    python3 tools/voice-isolate.py songs/musicxml/four-voices.musicxml /tmp/bass.musicxml P2:2

Then render it like any other score, e.g.:
    tools/score2mp3.sh /tmp/soprano.musicxml soprano.mp3

Requires only the standard library.
"""
import re
import sys

NOTE_RE = re.compile(r"<note[^>]*>.*?</note>", re.S)
VOICE_RE = re.compile(r"<voice>(\d+)</voice>")
PART_RE = re.compile(r'(<part id="([^"]+)">)(.*?)(</part>)', re.S)
SCORE_PART_RE = re.compile(r'<score-part id="([^"]+)">\s*<part-name[^>]*>([^<]*)</part-name>', re.S)


def resolve_voice(xml: str, spec: str) -> tuple:
    """Return (part_id, voice_number) for a "Name" or "Pid:voice" spec."""
    if ":" in spec:
        part_id, voice = spec.split(":", 1)
        return part_id, voice
    available = []
    for part_id, names in SCORE_PART_RE.findall(xml):
        for i, name in enumerate(names.split("/"), start=1):
            name = name.strip()
            available.append(name)
            if name.lower() == spec.strip().lower():
                return part_id, str(i)
    sys.exit(f"no part/voice matches {spec!r} -- known names: {', '.join(available)} "
              f"(or use <part-id>:<voice-number>, e.g. P1:1)")


def mute_note(note: str) -> str:
    """Turn a <note> into a same-duration rest: drop pitch/stem/lyrics."""
    note = re.sub(r"<pitch>.*?</pitch>", "<rest/>", note, flags=re.S)
    note = re.sub(r"<unpitched>.*?</unpitched>", "<rest/>", note, flags=re.S)
    note = re.sub(r"\n[ \t]*<stem>.*?</stem>", "", note, flags=re.S)
    note = re.sub(r"\n[ \t]*<lyric[^>]*>.*?</lyric>", "", note, flags=re.S)
    return note


def isolate(xml: str, target_part: str, target_voice: str) -> str:
    def do_part(m: "re.Match") -> str:
        open_tag, part_id, body, close_tag = m.groups()

        def do_note(nm: "re.Match") -> str:
            note = nm.group(0)
            voice_match = VOICE_RE.search(note)
            voice = voice_match.group(1) if voice_match else None
            keep = part_id == target_part and voice == target_voice
            return note if keep else mute_note(note)

        return open_tag + NOTE_RE.sub(do_note, body) + close_tag

    return PART_RE.sub(do_part, xml)


def main() -> None:
    if len(sys.argv) != 4:
        sys.exit("usage: voice-isolate.py <input.musicxml> <output.musicxml> <voice>")
    inp, outp, spec = sys.argv[1:4]
    xml = open(inp).read()
    part_id, voice = resolve_voice(xml, spec)
    open(outp, "w").write(isolate(xml, part_id, voice))
    print(f"wrote {outp} (isolated {spec!r} -> part {part_id}, voice {voice})")


if __name__ == "__main__":
    main()
