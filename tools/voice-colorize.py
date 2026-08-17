#!/usr/bin/env python3
"""voice-colorize.py -- color one voice's noteheads/stems in a MusicXML
score, the visual counterpart to voice-mix.sh's aural emphasis. Verovio (the
engine behind tools/score2mp3.sh and the scoryst Typst package) honors
MusicXML's standard `color` attribute on <note>, rendering that note's whole
glyph -- notehead, stem, ledger lines -- in the given color; everything else
stays black.

Verovio nests a note's lyric syllable inside that same SVG group, so by
default the lyric inherits the note's color too (its whole line, words
included). Pass --notes-only to keep lyrics black regardless of voice: this
adds an explicit color="#000000" on each <lyric> the colored note carries,
overriding the inherited color for just that element.

Works on any MusicXML, but is most useful on the output of voice-explode.py,
where each voice is already its own part: naming that part's label (e.g.
"Soprano") colors every note in it. On a score where voices still share a
part (e.g. <part-name>Soprano/Alto</part-name>), naming a "/"-separated
sub-label colors just the matching <voice>-tagged notes within that part.

Usage:
    python3 tools/voice-colorize.py <input.musicxml> <output.musicxml> <voice> [color=#FF0000] [--notes-only]

<voice> is a <part-name> label (matched case-insensitively; whole-name first,
then "/"-separated sub-label) or an explicit "<part-id>[:<voice-number>]".

Examples:
    python3 tools/voice-colorize.py songs/musicxml/four-voices.exploded.musicxml /tmp/soprano-red.musicxml soprano
    python3 tools/voice-colorize.py songs/musicxml/four-voices.musicxml /tmp/soprano-red.musicxml soprano
    python3 tools/voice-colorize.py songs/musicxml/four-voices.exploded.musicxml /tmp/alto-blue.musicxml alto "#2255CC"
    python3 tools/voice-colorize.py songs/musicxml/four-voices.exploded.musicxml /tmp/soprano-red.musicxml soprano --notes-only

Then render/typeset it like any other score, e.g. with the scoryst Typst
package, or tools/score2mp3.sh for an audio check.

Requires only the standard library.
"""
import re
import sys

NOTE_RE = re.compile(r"<note\b[^>]*>.*?</note>", re.S)
LYRIC_OPEN_RE = re.compile(r"<lyric\b")
VOICE_RE = re.compile(r"<voice>(\d+)</voice>")
PART_RE = re.compile(r'(<part id="([^"]+)">)(.*?)(</part>)', re.S)
SCORE_PART_RE = re.compile(r'<score-part id="([^"]+)">\s*<part-name[^>]*>([^<]*)</part-name>', re.S)


def resolve(xml: str, spec: str) -> tuple:
    """Return (part_id, voice_or_None) for a "Name", "Sub-label", or
    "<part-id>[:<voice-number>]" spec. `voice_or_None` of None means "the
    whole part"."""
    if ":" in spec:
        part_id, voice = spec.split(":", 1)
        return part_id, voice

    known = SCORE_PART_RE.findall(xml)
    spec_l = spec.strip().lower()

    for pid, name in known:
        if name.strip().lower() == spec_l:
            return pid, None  # whole part is this one voice

    for pid, name in known:
        labels = [n.strip() for n in name.split("/")]
        for i, label in enumerate(labels, start=1):
            if label.lower() == spec_l:
                return pid, str(i)

    listing = ", ".join(f"{pid} ({name.strip()})" for pid, name in known)
    sys.exit(f"no part/voice matches {spec!r} -- known parts: {listing}")


def colorize(xml: str, target_part: str, target_voice, color: str, notes_only: bool) -> str:
    def do_part(m: "re.Match") -> str:
        open_tag, part_id, body, close_tag = m.groups()
        if part_id != target_part:
            return open_tag + body + close_tag

        def do_note(nm: "re.Match") -> str:
            note = nm.group(0)
            if target_voice is not None:
                vm = VOICE_RE.search(note)
                if vm is None or vm.group(1) != target_voice:
                    return note
            note = re.sub(r"^<note\b", f'<note color="{color}"', note, count=1)
            if notes_only:
                note = LYRIC_OPEN_RE.sub('<lyric color="#000000"', note)
            return note

        return open_tag + NOTE_RE.sub(do_note, body) + close_tag

    return PART_RE.sub(do_part, xml)


def main() -> None:
    args = sys.argv[1:]
    notes_only = "--notes-only" in args
    if notes_only:
        args.remove("--notes-only")
    if len(args) < 3:
        sys.exit(
            "usage: voice-colorize.py <input.musicxml> <output.musicxml> <voice> "
            "[color=#FF0000] [--notes-only]"
        )
    inp, outp, spec = args[0:3]
    color = args[3] if len(args) > 3 else "#FF0000"
    xml = open(inp).read()
    part_id, voice = resolve(xml, spec)
    open(outp, "w").write(colorize(xml, part_id, voice, color, notes_only))
    where = f"part {part_id}" + (f", voice {voice}" if voice is not None else " (whole part)")
    scope = "notes only" if notes_only else "notes + lyrics"
    print(f"wrote {outp} (colorized {spec!r} -> {where}, {color}, {scope})")


if __name__ == "__main__":
    main()
