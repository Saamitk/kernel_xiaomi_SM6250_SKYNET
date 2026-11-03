#!/usr/bin/env python3
"""Validate relative links in this repository's Markdown documentation.

Only local links are checked; http(s), mailto and pure anchors are ignored.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LINK = re.compile(r"\[[^\]]*\]\(([^)]+)\)")

TARGETS = [
    ROOT / "README.md",
    ROOT / "CHANGELOG.md",
    ROOT / "CONTRIBUTING.md",
    ROOT / ".github" / "PULL_REQUEST_TEMPLATE.md",
]
TARGETS += sorted((ROOT / "docs").glob("*.md"))
TARGETS += sorted((ROOT / ".github" / "ISSUE_TEMPLATE").glob("*.md"))


def main() -> int:
    """Return 0 when every relative link resolves, 1 otherwise."""
    broken: list[str] = []
    checked = 0

    for source in TARGETS:
        if not source.is_file():
            continue
        checked += 1
        for link in LINK.findall(source.read_text(encoding="utf-8")):
            parts = link.strip().split()
            target = parts[0] if parts else ""
            target = target.split("#", 1)[0]
            if not target or target.startswith(("http://", "https://", "mailto:", "www.")):
                continue
            resolved = (source.parent / target).resolve()
            if not resolved.exists():
                broken.append(f"{source.relative_to(ROOT)} -> {link}")

    if broken:
        print("Broken relative links:", file=sys.stderr)
        for item in broken:
            print(f"  {item}", file=sys.stderr)
        return 1

    print(f"OK: {checked} Markdown files, all relative links resolve")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
