#!/usr/bin/env python3
"""Validate BaseSwiftUI repo-owned skill discovery and routing artifacts."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[4]
SKILLS_ROOT = ROOT / ".codex" / "skills"
CASES_PATH = Path(__file__).resolve().parents[1] / "assets" / "routing-cases.json"
MAX_DESCRIPTION_WORDS = 40
MAX_DESCRIPTION_CHARS = 300
MAX_PROJECT_SKILL_LINES = 200
MAX_FIGMA_SKILL_LINES = 100
MAX_PROJECT_DESCRIPTION_WORDS = 450
MAX_BOOTSTRAP_WORDS = 900
BOOTSTRAP_BUDGETS = {
    "AGENTS.md": (320, 50),
    "CLAUDE.md": (80, 12),
    "AI-Workflow/AGENTS.md": (180, 30),
    "AI-Workflow/WORKFLOW_AI.md": (450, 70),
    "AI-Workflow/AI_USAGE.md": (130, 25),
    "AI-Workflow/STARTER_PROMPT.txt": (40, 6),
}


def frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---\n", 4)
    if end < 0:
        return {}
    values: dict[str, str] = {}
    current = ""
    for line in text[4:end].splitlines():
        match = re.match(r"^([a-zA-Z0-9_-]+):\s*(.*)$", line)
        if match:
            current = match.group(1)
            value = match.group(2).strip().strip('"')
            values[current] = value if value not in {">", ">-", "|"} else ""
        elif current and line.startswith((" ", "\t")):
            values[current] = f"{values[current]} {line.strip()}".strip()
    return values


def validate_skill(skill_dir: Path) -> list[str]:
    errors: list[str] = []
    skill_file = skill_dir / "SKILL.md"
    if not skill_file.exists():
        return [f"{skill_dir}: missing SKILL.md"]
    text = skill_file.read_text(encoding="utf-8")
    metadata = frontmatter(text)
    name = metadata.get("name", "")
    description = metadata.get("description", "")
    if name != skill_dir.name:
        errors.append(f"{skill_file}: name '{name}' != folder '{skill_dir.name}'")
    if not description:
        errors.append(f"{skill_file}: missing description")
    if skill_dir.name != "weekly-report":
        description_words = len(description.split())
        if description_words > MAX_DESCRIPTION_WORDS:
            errors.append(
                f"{skill_file}: description has {description_words} words "
                f"(max {MAX_DESCRIPTION_WORDS})"
            )
        if len(description) > MAX_DESCRIPTION_CHARS:
            errors.append(
                f"{skill_file}: description has {len(description)} chars "
                f"(max {MAX_DESCRIPTION_CHARS})"
            )
        if len(text.splitlines()) > MAX_PROJECT_SKILL_LINES:
            errors.append(
                f"{skill_file}: exceeds {MAX_PROJECT_SKILL_LINES} lines"
            )

    agent_file = skill_dir / "agents" / "openai.yaml"
    if skill_dir.name != "weekly-report":
        if not agent_file.exists():
            errors.append(f"{skill_dir}: missing agents/openai.yaml")
        else:
            agent_text = agent_file.read_text(encoding="utf-8")
            if f"${name}" not in agent_text:
                errors.append(f"{agent_file}: default_prompt does not mention ${name}")

    for relative in re.findall(r"`((?:references|scripts|assets)/[^`]+)`", text):
        if any(char in relative for char in " *{}[]<>"):
            continue
        if not (skill_dir / relative).exists():
            errors.append(f"{skill_file}: missing referenced path {relative}")
    return errors


def main() -> int:
    errors: list[str] = []
    names: set[str] = set()
    project_description_words = 0
    bootstrap_words = 0

    for relative, (max_words, max_lines) in BOOTSTRAP_BUDGETS.items():
        path = ROOT / relative
        if not path.exists():
            errors.append(f"{path}: missing bootstrap file")
            continue
        text = path.read_text(encoding="utf-8")
        words = len(text.split())
        lines = len(text.splitlines())
        bootstrap_words += words
        if words > max_words:
            errors.append(f"{path}: {words} words exceeds budget {max_words}")
        if lines > max_lines:
            errors.append(f"{path}: {lines} lines exceeds budget {max_lines}")

    if bootstrap_words > MAX_BOOTSTRAP_WORDS:
        errors.append(
            f"bootstrap docs: {bootstrap_words} words exceeds budget "
            f"{MAX_BOOTSTRAP_WORDS}"
        )

    for skill_dir in sorted(path for path in SKILLS_ROOT.iterdir() if path.is_dir()):
        errors.extend(validate_skill(skill_dir))
        names.add(skill_dir.name)
        if skill_dir.name.startswith("baseswiftui-"):
            skill_text = (skill_dir / "SKILL.md").read_text(encoding="utf-8")
            project_description_words += len(
                frontmatter(skill_text).get("description", "").split()
            )

    figma_skill = SKILLS_ROOT / "baseswiftui-figma-ui" / "SKILL.md"
    figma_text = figma_skill.read_text(encoding="utf-8")
    figma_normalized = re.sub(r"\s+", " ", figma_text)
    if len(figma_text.splitlines()) > MAX_FIGMA_SKILL_LINES:
        errors.append(
            f"{figma_skill}: exceeds fast-path budget of {MAX_FIGMA_SKILL_LINES} lines"
        )
    if "skill://" in figma_text:
        errors.append(f"{figma_skill}: fast route must not preload external skills")
    for required in (
        "get_design_context` once",
        "Do not run prompt-injection scanning, GitNexus",
        "another project skill, build, tests, simulator",
    ):
        if required not in figma_normalized:
            errors.append(f"{figma_skill}: missing fast-path contract '{required}'")

    if project_description_words > MAX_PROJECT_DESCRIPTION_WORDS:
        errors.append(
            f"BaseSwiftUI descriptions: {project_description_words} words "
            f"exceeds budget {MAX_PROJECT_DESCRIPTION_WORDS}"
        )

    cases = json.loads(CASES_PATH.read_text(encoding="utf-8"))
    case_ids: set[str] = set()
    for case in cases:
        if case.get("id") in case_ids:
            errors.append(f"{CASES_PATH}: duplicate id {case.get('id')}")
        case_ids.add(case.get("id"))
        if case.get("expected") not in names:
            errors.append(f"{CASES_PATH}: unknown expected skill {case.get('expected')}")
        if not case.get("prompt"):
            errors.append(f"{CASES_PATH}: empty prompt for {case.get('id')}")
        expected_mode = case.get("expected_mode")
        if expected_mode and expected_mode not in {
            "quick", "verified", "analyze", "assets", "compare", "flow"
        }:
            errors.append(
                f"{CASES_PATH}: invalid expected_mode {expected_mode} "
                f"for {case.get('id')}"
            )

    if errors:
        print("agent setup validation: FAILED")
        for error in errors:
            print(f"- {error}")
        return 1
    print(
        "agent setup validation: OK "
        f"({len(names)} skills, {len(cases)} routing cases, "
        f"{project_description_words} description words, "
        f"{bootstrap_words} bootstrap words)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
