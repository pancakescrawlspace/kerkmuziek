"""Maps each regenerate action to the tools/*.sh|py commands it runs, and
runs a Job in a background thread.

Every command list is argv-style (never a shell string) and every command
runs with cwd=PROJECT_ROOT, exactly matching how tools/README.md documents
running these scripts by hand from the repo root.
"""
import subprocess
import threading
from pathlib import Path

from django.conf import settings
from django.utils import timezone

from .files import list_midi, list_musicxml, resolve_source
from .models import Job

ROOT = Path(settings.PROJECT_ROOT)


def _midi_commands(musicxml_abs: Path, name: str) -> list[list[str]]:
    # score2midi.sh defaults its output next to the *source* MusicXML file
    # (songs/musicxml/) if not given explicitly -- the canonical MIDI lives
    # in songs/audio/, which is also all files.py's MIDI tab lists, so the
    # output path must always be passed explicitly here.
    return [
        [
            "tools/score2midi.sh",
            str(musicxml_abs.relative_to(ROOT)),
            f"songs/audio/{name}.mid",
        ]
    ]


def _mp3_commands(musicxml_abs: Path, name: str) -> list[list[str]]:
    # same reasoning as _midi_commands above -- score2mp3.sh's default
    # output path is next to the source, not songs/audio/.
    return [
        [
            "tools/score2mp3.sh",
            str(musicxml_abs.relative_to(ROOT)),
            f"songs/audio/{name}.mp3",
        ]
    ]


def _pdf_scoryst_commands(musicxml_abs: Path, name: str) -> list[list[str]]:
    return [["tools/compile-scores.sh", f"songs/scoryst/{name}.typ"]]


def _pdf_typst_commands(musicxml_abs: Path, name: str) -> list[list[str]]:
    return [
        [
            "python3",
            "tools/musicxml2svg.py",
            str(musicxml_abs.relative_to(ROOT)),
            f"songs/musicxml-svg/{name}",
        ],
        [
            "typst",
            "compile",
            "--root",
            ".",
            "--font-path",
            "songs/typst/fonts",
            f"songs/typst/{name}.typ",
            f"songs/typst/{name}.pdf",
        ],
    ]


def _mp3_from_midi_commands(midi_abs: Path, name: str) -> list[list[str]]:
    return [["tools/mid2mp3-fluidsynth.sh", str(midi_abs.relative_to(ROOT))]]


def _pdf_verovio_direct_commands(musicxml_abs: Path, name: str) -> list[list[str]]:
    # songs/compare-lilypond/verovio-direct-demo.py: Verovio -> SVG (one per
    # page) -> rsvg-convert -> one-page PDFs -> pdfunite -- the same
    # Verovio-to-SVG step scoryst and the typst pipeline both use
    # internally, minus Typst, and unlike pdf-mscore this needs no Docker
    # -specific runtime -- rsvg-convert and pdfunite are plain CLI tools,
    # already required on macOS by the script itself (see tools/README.md).
    return [
        [
            "python3",
            "songs/compare-lilypond/verovio-direct-demo.py",
            str(musicxml_abs.relative_to(ROOT)),
            f"songs/verovio-direct-pdf/{name}.pdf",
        ]
    ]


def _pdf_mscore_commands(musicxml_abs: Path, name: str) -> list[list[str]]:
    # Only actually works in the Docker image, which installs MuseScore's
    # AppImage at /opt/musescore -- see server/Dockerfile. Outside Docker
    # this just fails with "command not found", caught below like any
    # other missing tool. `--platform offscreen` doesn't work for MuseScore
    # 4's CLI (see the Dockerfile's MuseScore install step); xvfb-run does.
    return [
        [
            "xvfb-run",
            "-a",
            "/opt/musescore/usr/bin/mscore4portable",
            "-o",
            f"songs/mscore-pdf/{name}.pdf",
            str(musicxml_abs.relative_to(ROOT)),
        ]
    ]


# action key -> (label, source category, availability check, command builder)
ACTIONS = {
    "midi": ("Regenerate MIDI", "musicxml", None, _midi_commands),
    "mp3": ("Regenerate MP3", "musicxml", None, _mp3_commands),
    "pdf-scoryst": (
        "Regenerate PDF (scoryst)",
        "musicxml",
        lambda entry: entry["has_scoryst_typ"],
        _pdf_scoryst_commands,
    ),
    "pdf-typst": (
        "Regenerate PDF (typst)",
        "musicxml",
        lambda entry: entry["has_typst_typ"],
        _pdf_typst_commands,
    ),
    "mp3-from-midi": ("Regenerate MP3", "midi", None, _mp3_from_midi_commands),
    "pdf-mscore": (
        "Regenerate PDF (MuseScore)",
        "musicxml",
        None,
        _pdf_mscore_commands,
    ),
    "pdf-verovio-direct": (
        "Regenerate PDF (Verovio direct)",
        "musicxml",
        None,
        _pdf_verovio_direct_commands,
    ),
}

_LISTER_BY_KIND = {"musicxml": list_musicxml, "midi": list_midi}


def start_job(action: str, source_path: str) -> Job:
    """Validate action/source_path, create the Job row, and hand it to a
    background thread. Returns the Job immediately (still pending).
    """
    if action not in ACTIONS:
        raise ValueError(f"unknown action {action!r}")
    label, kind, available, _ = ACTIONS[action]

    lister = _LISTER_BY_KIND[kind]
    source_abs = resolve_source(source_path, lister)  # raises ValueError if not listed

    if available is not None:
        entry = next(e for e in lister() if e["path"] == source_path)
        if not available(entry):
            raise ValueError(f"{action!r} is not available for {source_path!r}")

    job = Job.objects.create(action=action, source_path=source_path, target_label=label)
    thread = threading.Thread(target=_run, args=(job.id, source_abs), daemon=True)
    thread.start()
    return job


def _run(job_id: int, source_abs: Path) -> None:
    job = Job.objects.get(id=job_id)
    job.status = Job.RUNNING
    job.save(update_fields=["status"])

    _, _, _, build_commands = ACTIONS[job.action]
    name = source_abs.stem
    log_parts = []
    ok = True
    try:
        for command in build_commands(source_abs, name):
            log_parts.append("$ " + " ".join(command))
            result = subprocess.run(
                command, cwd=ROOT, capture_output=True, text=True
            )
            log_parts.append(result.stdout)
            if result.stderr:
                log_parts.append(result.stderr)
            if result.returncode != 0:
                ok = False
                log_parts.append(f"[exit {result.returncode}]")
                break
    except Exception as exc:  # e.g. command not found
        ok = False
        log_parts.append(f"[error] {exc}")

    job.status = Job.SUCCESS if ok else Job.FAILED
    job.log = "\n".join(part for part in log_parts if part)
    job.finished_at = timezone.now()
    job.save(update_fields=["status", "log", "finished_at"])
