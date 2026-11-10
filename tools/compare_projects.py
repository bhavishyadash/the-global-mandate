"""Read-only comparison of two Godot project folders.

Run: python tools/compare_projects.py PATH_TO_OTHER_PROJECT
Exit 0 if equal, 1 if differences exist, 2 for invalid project folders.
"""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IGNORED_DIRS = {".git", ".godot", "docs", "tools", "__pycache__"}
IGNORED_NAMES = {"README.md", "test_save.json", "test_save.json.bak"}
IGNORED_SUFFIXES = {".log", ".uid", ".import"}


def files(root: Path) -> dict[str, Path]:
    result = {}
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        if any(part in IGNORED_DIRS for part in relative.parts):
            continue
        if path.is_file() and path.name not in IGNORED_NAMES and path.suffix not in IGNORED_SUFFIXES:
            result[relative.as_posix()] = path
    return result


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            hasher.update(block)
    return hasher.hexdigest()


def compare(left: Path, right: Path) -> list[tuple[str, str]]:
    a, b = files(left), files(right)
    differences = []
    for name in sorted(a.keys() | b.keys()):
        if name not in a:
            differences.append(("Only in other", name))
        elif name not in b:
            differences.append(("Only in repository", name))
        elif digest(a[name]) != digest(b[name]):
            differences.append(("Different", name))
    return differences


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    other = Path(sys.argv[1]).expanduser().resolve()
    if not (ROOT / "project.godot").is_file() or not (other / "project.godot").is_file():
        print("Both directories must contain project.godot.")
        return 2
    try:
        differences = compare(ROOT, other)
    except OSError as error:
        print(f"Could not compare files: {error}")
        return 2
    for kind, name in differences:
        print(f"{kind}: {name}")
    print(f"{len(differences)} difference(s); no files modified.")
    return 1 if differences else 0


if __name__ == "__main__":
    raise SystemExit(main())
