"""Live filesystem listings for the four tabs. songs/ is the source of
truth -- nothing here is cached or stored in the database, every call
re-globs. Also the single place that validates a source_path posted by the
frontend actually is one of these files, before jobs.py is allowed to run
anything with it.
"""
from pathlib import Path

from django.conf import settings

SONGS = Path(settings.PROJECT_ROOT) / "songs"
MUSICXML_DIR = SONGS / "musicxml"
AUDIO_DIR = SONGS / "audio"
SCORYST_DIR = SONGS / "scoryst"
TYPST_DIR = SONGS / "typst"
VEROVIO_DIRECT_PDF_DIR = SONGS / "verovio-direct-pdf"
MUSICXML_SVG_DIR = SONGS / "musicxml-svg"


def _entry(path: Path) -> dict:
    stat = path.stat()
    return {
        "name": path.stem,
        "path": str(path.relative_to(settings.PROJECT_ROOT)),
        "size": stat.st_size,
        "mtime": stat.st_mtime,
    }


def list_musicxml() -> list[dict]:
    entries = []
    for path in sorted(MUSICXML_DIR.glob("*.musicxml")):
        entry = _entry(path)
        entry["has_scoryst_typ"] = (SCORYST_DIR / f"{path.stem}.typ").exists()
        entry["has_typst_typ"] = (TYPST_DIR / f"{path.stem}.typ").exists()
        entries.append(entry)
    return entries


def list_midi() -> list[dict]:
    paths = sorted({*AUDIO_DIR.glob("*.mid"), *AUDIO_DIR.glob("*.midi")})
    return [_entry(path) for path in paths]


def list_mp3() -> list[dict]:
    return [_entry(path) for path in sorted(AUDIO_DIR.glob("*.mp3"))]


def list_pdfs() -> list[dict]:
    entries = []
    for path in sorted(VEROVIO_DIRECT_PDF_DIR.glob("*.pdf")):
        entry = _entry(path)
        entry["pipeline"] = "verovio-direct"
        entries.append(entry)
    return entries


def list_svg() -> list[dict]:
    return [_entry(path) for path in sorted(MUSICXML_SVG_DIR.glob("*.svg"))]


LISTERS = {
    "musicxml": list_musicxml,
    "midi": list_midi,
    "mp3": list_mp3,
    "svg": list_svg,
    "pdf": list_pdfs,
}


def resolve_source(relative_path: str, lister) -> Path:
    """Re-list `lister`'s category and confirm relative_path is one of its
    current entries. Raises ValueError otherwise. This is the only path a
    client-supplied path string is allowed to reach jobs.py through -- never
    trust it directly.
    """
    for entry in lister():
        if entry["path"] == relative_path:
            return Path(settings.PROJECT_ROOT) / relative_path
    raise ValueError(f"{relative_path!r} is not a currently listed file")
