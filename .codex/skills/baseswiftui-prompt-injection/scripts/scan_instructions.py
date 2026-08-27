#!/usr/bin/env python3
"""Scan instruction-like text and DOCX content for prompt-injection signals."""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


TEXT_SUFFIXES = {".md", ".txt", ".yaml", ".yml", ".json"}
PATTERNS = {
    "instruction_override": re.compile(
        r"ignore\s+(?:all|any|the|previous|prior)\s+instructions|"
        r"override\s+(?:the\s+)?(?:policy|instructions)|disable\s+safety",
        re.IGNORECASE,
    ),
    "hidden_prompt": re.compile(
        r"reveal\s+(?:the\s+)?(?:system\s+prompt|developer\s+message)|"
        r"print\s+(?:the\s+)?(?:system\s+prompt|developer\s+message)",
        re.IGNORECASE,
    ),
    "secret_request": re.compile(
        r"(?:reveal|print|send|upload|exfiltrat\w*)\s+(?:the\s+|any\s+)?"
        r"(?:api[ -]?key|password|credential|secret|access[ -]?token)s?\b",
        re.IGNORECASE,
    ),
    "privileged_command": re.compile(
        r"(?:run|execute)[^\n]{0,40}(?:sudo\b|chmod\s+777\b)|"
        r"curl\s+[^\n|]+\|\s*(?:ba)?sh\b",
        re.IGNORECASE,
    ),
    "destructive_command": re.compile(
        r"\brm\s+-rf\b|\bgit\s+reset\s+--hard\b|\bgit\s+clean\s+-[a-z]*f",
        re.IGNORECASE,
    ),
}


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    category: str
    excerpt: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--path", action="append", type=Path, default=[])
    parser.add_argument("--exclude", action="append", default=[])
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--max-bytes", type=int, default=2_000_000)
    return parser.parse_args()


def iter_candidates(paths: Iterable[Path], exclusions: set[str]) -> Iterable[Path]:
    seen: set[Path] = set()
    for raw_path in paths:
        path = raw_path.expanduser().resolve()
        if path.is_file():
            candidates = [path]
        elif path.is_dir():
            candidates = (
                item
                for item in path.rglob("*")
                if item.is_file()
                and not any(part in exclusions for part in item.parts)
            )
        else:
            continue

        for candidate in candidates:
            if candidate in seen:
                continue
            if candidate.suffix.lower() in TEXT_SUFFIXES | {".docx"}:
                seen.add(candidate)
                yield candidate


def read_docx(path: Path) -> str:
    with zipfile.ZipFile(path) as archive:
        xml = archive.read("word/document.xml").decode("utf-8", errors="replace")
    xml = re.sub(r"</w:p>|<w:br[^>]*/>", "\n", xml)
    return re.sub(r"<[^>]+>", "", xml)


def read_text(path: Path, max_bytes: int) -> str:
    if path.stat().st_size > max_bytes and path.suffix.lower() != ".docx":
        raise ValueError(f"larger than --max-bytes ({max_bytes})")
    if path.suffix.lower() == ".docx":
        return read_docx(path)
    return path.read_text(encoding="utf-8", errors="replace")


def scan(path: Path, text: str) -> list[Finding]:
    findings: list[Finding] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        normalized = " ".join(line.split())
        for category, pattern in PATTERNS.items():
            match = pattern.search(line)
            if not match:
                continue
            protective_prefix = line[: match.start()].lower()
            if category in {"hidden_prompt", "secret_request"} and re.search(
                r"\b(?:never|do not|don't|must not|avoid|reject)\b",
                protective_prefix,
            ):
                continue
            findings.append(
                Finding(
                    path=str(path),
                    line=line_number,
                    category=category,
                    excerpt=normalized[:240],
                )
            )
    return findings


def main() -> int:
    args = parse_args()
    exclusions = {".git", "Pods", "node_modules", *args.exclude}
    candidates = list(iter_candidates([args.root, *args.path], exclusions))
    findings: list[Finding] = []
    errors: list[dict[str, str]] = []

    for path in candidates:
        try:
            findings.extend(scan(path, read_text(path, args.max_bytes)))
        except (OSError, ValueError, KeyError, zipfile.BadZipFile) as error:
            errors.append({"path": str(path), "error": str(error)})

    payload = {
        "files_scanned": len(candidates),
        "findings": [asdict(finding) for finding in findings],
        "errors": errors,
        "disposition": "manual_context_classification_required" if findings else "clean",
    }
    if args.json:
        json.dump(payload, sys.stdout, indent=2, ensure_ascii=False)
        print()
    else:
        print(f"files scanned: {len(candidates)}")
        for finding in findings:
            print(
                f"{finding.path}:{finding.line}: {finding.category}: "
                f"{finding.excerpt}"
            )
        for error in errors:
            print(f"warning: {error['path']}: {error['error']}", file=sys.stderr)
        print(f"disposition: {payload['disposition']}")
    return 0 if not errors else 2


if __name__ == "__main__":
    raise SystemExit(main())
