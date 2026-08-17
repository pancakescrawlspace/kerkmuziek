#!/usr/bin/env python3
"""voice-mix.py -- render a MusicXML score to MIDI with an independent
volume per part, so one voice (e.g. the one you're studying) comes through
louder than the rest.

Companion to voice-explode.py: run that first so each voice is its own
<part> -- Verovio assigns one MIDI channel per <part>, but does not split
channels within a part by voice, so per-voice volume needs one part per
voice. (You can also point this straight at a score that already has one
voice per part; voices left sharing a part will share that part's volume.)

It assigns every part its own MIDI channel (1..N, in score order), injects
<midi-instrument> into a copy of the MusicXML (the file on disk is
untouched, and any pre-existing <midi-instrument> is replaced), renders to
MIDI via Verovio, then inserts one Control Change #7 (Channel Volume) event
per channel at time 0 -- confirmed against this project's FluidSynth
rendering to give roughly a 32 dB spread between CC7 values of 20 and 127.

Usage:
    python3 tools/voice-mix.py <input.musicxml> <output.mid> <spotlight-voice> \
        [spotlight-volume=127] [background-volume=40] [gm-program=1]

<spotlight-voice> is a <part-name> label (matched case-insensitively) or an
explicit <part-id>, as in voice-isolate.py. Volumes are MIDI Channel Volume
values, 0-127.

Example:
    python3 tools/voice-explode.py songs/musicxml/four-voices.musicxml /tmp/exploded.musicxml
    python3 tools/voice-mix.py /tmp/exploded.musicxml /tmp/soprano-mix.mid soprano

Requires the `verovio` and `mido` packages (`pip install verovio mido`).
"""
import io
import re
import sys
import base64
import verovio
import mido

MAX_MIDI_CHANNELS = 16
SCORE_PART_RE = re.compile(r'(<score-part id="([^"]+)">\s*<part-name[^>]*>([^<]*)</part-name>)', re.S)


def resolve_part(xml: str, spec: str) -> str:
    known = [(pid, name.strip()) for _, pid, name in SCORE_PART_RE.findall(xml)]
    for pid, name in known:
        if spec == pid or spec.lower() == name.lower():
            return pid
    listing = ", ".join(f"{pid} ({name})" for pid, name in known)
    sys.exit(f"no part matches {spec!r} -- known parts: {listing}")


def assign_channels(xml: str, program: int) -> tuple:
    """Strip any existing <midi-instrument>, give every <score-part> a fresh
    1-based MIDI channel, and return the modified XML plus a
    {part_id: channel} map."""
    xml = re.sub(r"<midi-instrument.*?</midi-instrument>", "", xml, flags=re.S)
    known = [(pid, name) for _, pid, name in SCORE_PART_RE.findall(xml)]
    if len(known) > MAX_MIDI_CHANNELS:
        sys.exit(f"{len(known)} parts but MIDI only has {MAX_MIDI_CHANNELS} channels")
    channels = {pid: i + 1 for i, (pid, _) in enumerate(known)}

    def add(m):
        whole, pid, _ = m.groups()
        instr = (
            f'\n    <midi-instrument id="{pid}-I1">'
            f"<midi-channel>{channels[pid]}</midi-channel>"
            f"<midi-program>{program}</midi-program></midi-instrument>"
        )
        return whole + instr

    return SCORE_PART_RE.sub(add, xml), channels


def render_midi(xml: str) -> bytes:
    tk = verovio.toolkit()
    if not tk.loadData(xml):
        sys.exit("verovio failed to load the score")
    return base64.b64decode(tk.renderToMIDI())


def set_volumes(midi_bytes: bytes, channel_volume: dict) -> "mido.MidiFile":
    """Insert one Control Change #7 (Channel Volume) at time 0 per channel
    actually used in the MIDI, at the volume given for its channel."""
    mid = mido.MidiFile(file=io.BytesIO(midi_bytes))
    for track in mid.tracks:
        used = {msg.channel for msg in track if hasattr(msg, "channel")}
        for chan in used:
            vol = channel_volume.get(chan, 100)
            track.insert(0, mido.Message("control_change", control=7, value=vol, channel=chan, time=0))
    return mid


def main() -> None:
    if len(sys.argv) < 4:
        sys.exit(
            "usage: voice-mix.py <input.musicxml> <output.mid> <spotlight-voice> "
            "[spotlight-volume=127] [background-volume=40] [gm-program=1]"
        )
    inp, outp, spotlight = sys.argv[1:4]
    spot_vol = int(sys.argv[4]) if len(sys.argv) > 4 else 127
    bg_vol = int(sys.argv[5]) if len(sys.argv) > 5 else 40
    program = int(sys.argv[6]) if len(sys.argv) > 6 else 1

    xml = open(inp).read()
    spotlight_id = resolve_part(xml, spotlight)
    xml, channels = assign_channels(xml, program)

    # channels above is 1-based (MusicXML convention); mido channels are 0-based.
    channel_volume = {
        chan - 1: (spot_vol if pid == spotlight_id else bg_vol) for pid, chan in channels.items()
    }

    mid = set_volumes(render_midi(xml), channel_volume)
    mid.save(outp)
    print(f"wrote {outp} (spotlight={spotlight!r} -> part {spotlight_id} @ {spot_vol}, "
          f"others @ {bg_vol})")


if __name__ == "__main__":
    main()
