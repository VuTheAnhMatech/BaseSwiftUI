#!/usr/bin/env python3
"""Find SwiftUI API migration candidates without changing source files."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


PATTERNS = {
    "NavigationView": re.compile(r"\bNavigationView\s*\{"),
    "navigationBarItems": re.compile(r"\.navigationBarItems\s*\("),
    "actionSheet": re.compile(r"\.actionSheet\s*\("),
    "edgesIgnoringSafeArea": re.compile(r"\.edgesIgnoringSafeArea\s*\("),
    "unscopedAnimation": re.compile(r"\.animation\s*\([^,\n]+\)"),
    "foregroundColor": re.compile(r"\.foregroundColor\s*\("),
    "cornerRadius": re.compile(r"\.cornerRadius\s*\("),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path("BaseSwiftUI"))
    parser.add_argument("--json", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.root.expanduser().resolve()
    findings: list[dict[str, object]] = []
    for path in sorted(root.rglob("*.swift")):
        for line_number, line in enumerate(
            path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1
        ):
            for candidate, pattern in PATTERNS.items():
                if pattern.search(line):
                    findings.append(
                        {
                            "candidate": candidate,
                            "path": str(path),
                            "line": line_number,
                            "excerpt": line.strip()[:200],
                        }
                    )
    if args.json:
        print(json.dumps({"root": str(root), "findings": findings}, indent=2))
    else:
        for finding in findings:
            print(
                f"{finding['path']}:{finding['line']}: "
                f"{finding['candidate']}: {finding['excerpt']}"
            )
        print(f"review candidates: {len(findings)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
