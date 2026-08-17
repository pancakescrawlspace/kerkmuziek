#!/usr/bin/env python3
"""choirify.py -- export a MusicXML score's MIDI with a chosen General MIDI
instrument.

It injects a <midi-instrument><midi-program>N</midi-program> into every
<score-part> of a *copy* of the MusicXML (the file on disk is not modified),
then exports the MIDI through Verovio. Render the resulting .mid to audio with
tools/mid2mp3-fluidsynth.sh (portable) or tools/mid2mp3.sh (macOS).

Usage:
    python3 tools/choirify.py <input.musicxml> <output.mid> [gm_program]

gm_program is the 1-based General MIDI program number (default 1, Acoustic
Grand Piano -- matching score2midi.sh/score2mp3.sh's "omit -p for piano"
default). Useful voices: 53 Choir Aahs, 54 Voice Oohs, 55 Synth Voice.

Example (how the committed *.choir.mp3 were made):
    python3 tools/choirify.py songs/musicxml/four-voices.musicxml /tmp/fv.mid 53
    SOUNDFONT=/path/GeneralUser-GS.sf2 \
        tools/mid2mp3-fluidsynth.sh /tmp/fv.mid four-voices.choir.mp3

Requires the `verovio` Python package.
"""
import sys
import re
import base64
import verovio

GM_NAMES = {1: "Acoustic Grand Piano", 53: "Choir Aahs", 54: "Voice Oohs", 55: "Synth Voice"}


def choirify(xml: str, program: int) -> str:
    ids = re.findall(r'<score-part id="([^"]+)">', xml)
    chan = {pid: i + 1 for i, pid in enumerate(ids)}
    name = GM_NAMES.get(program, f"GM program {program}")

    def add(m: "re.Match") -> str:
        pid, inner = m.group(1), m.group(2)
        instr = (
            f'\n      <score-instrument id="{pid}-I1">'
            f"<instrument-name>{name}</instrument-name></score-instrument>"
            f'\n      <midi-instrument id="{pid}-I1">'
            f"<midi-channel>{chan[pid]}</midi-channel>"
            f"<midi-program>{program}</midi-program></midi-instrument>"
        )
        return f'<score-part id="{pid}">{inner}{instr}\n    </score-part>'

    return re.sub(r'<score-part id="([^"]+)">(.*?)\s*</score-part>', add, xml, flags=re.S)


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit("usage: choirify.py <input.musicxml> <output.mid> [gm_program=1]")
    inp, outp = sys.argv[1], sys.argv[2]
    program = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    xml = open(inp).read()
    tk = verovio.toolkit()
    if not tk.loadData(choirify(xml, program)):
        sys.exit(f"verovio failed to load {inp}")
    open(outp, "wb").write(base64.b64decode(tk.renderToMIDI()))
    print(f"wrote {outp} ({GM_NAMES.get(program, 'GM program ' + str(program))})")


if __name__ == "__main__":
    main()
