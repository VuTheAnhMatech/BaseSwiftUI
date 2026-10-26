#!/usr/bin/env python3
"""Validate BaseSwiftUI repo-owned skill discovery and routing artifacts."""

from __future__ import annotations

import argparse
import copy
import json
import math
import re
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[4]
SKILLS_ROOT = ROOT / ".codex" / "skills"
CASES_PATH = Path(__file__).resolve().parents[1] / "assets" / "routing-cases.json"
MAX_DESCRIPTION_WORDS = 40
MAX_DESCRIPTION_CHARS = 300
MAX_PROJECT_SKILL_LINES = 200
MAX_FIGMA_SKILL_LINES = 100
MAX_PROJECT_DESCRIPTION_WORDS = 300
MAX_BOOTSTRAP_WORDS = 900
ROUTE_MODES = {
    "baseswiftui-figma-ui": {"quick", "screen", "draft", "analyze", "assets", "compare", "flow"},
    "baseswiftui-swiftui-ui": {"local", "screen"},
    "baseswiftui-architecture": {"change", "models", "guidelines"},
    "baseswiftui-swiftui-review": {"source", "debug", "test", "api", "trace"},
}
EXPECTED_SKILLS = {
    "baseswiftui-swiftui-ui", "baseswiftui-figma-ui", "baseswiftui-iap-flow",
    "baseswiftui-architecture", "baseswiftui-swiftui-review",
    "baseswiftui-security-review", "baseswiftui-agent-maintenance",
    "baseswiftui-prompt-injection", "weekly-report",
}
COUNT_FIELDS = {"builds", "edits", "index_refreshes", "design_context_calls"}
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
    for relative in re.findall(r"`(\.codex/skills/[^`]+)`", text):
        if not (ROOT / relative).is_file():
            errors.append(f"{skill_file}: missing cross-skill reference {relative}")
    return errors


def validate_cases(cases: object, names: set[str]) -> list[str]:
    """Validate expectations only; this does not invoke or predict an agent."""
    if not isinstance(cases, list) or not cases:
        return ["routing cases must be a non-empty list"]
    errors: list[str] = []
    seen: set[str] = set()
    for case in cases:
        if not isinstance(case, dict):
            errors.append("routing case must be an object")
            continue
        case_id = case.get("id")
        if not isinstance(case_id, str) or not case_id.strip():
            errors.append("routing case requires a non-empty id")
            continue
        if case_id in seen:
            errors.append(f"{case_id}: duplicate case id")
        seen.add(case_id)
        primary = case.get("expected")
        if "expected" not in case or (primary is not None and (
            not isinstance(primary, str) or primary not in names
        )):
            errors.append(f"{case_id}: unknown expected skill {primary}")
        if not isinstance(case.get("prompt"), str) or not case["prompt"].strip():
            errors.append(f"{case_id}: empty prompt")
        mode = case.get("expected_mode")
        if mode is not None and (
            not isinstance(mode, str) or not isinstance(primary, str)
            or mode not in ROUTE_MODES.get(primary, set())
        ):
            errors.append(f"{case_id}: invalid mode {mode} for {primary}")
        forbidden = case.get("forbidden_skills", [])
        if not isinstance(forbidden, list) or any(
            not isinstance(name, str) or name not in names for name in forbidden
        ):
            errors.append(f"{case_id}: invalid forbidden_skills")
        elif primary in forbidden:
            errors.append(f"{case_id}: primary skill cannot be forbidden")
        required_refs = case.get("required_references", [])
        forbidden_refs = case.get("forbidden_references", [])
        for field, refs in (("required_references", required_refs), ("forbidden_references", forbidden_refs)):
            if not valid_references(refs):
                errors.append(f"{case_id}: invalid {field}; use existing repo-relative skill references")
        if valid_references(required_refs) and valid_references(forbidden_refs):
            if set(required_refs) & set(forbidden_refs):
                errors.append(f"{case_id}: required reference cannot be forbidden")
        if primary is None and required_refs:
            errors.append(f"{case_id}: no-skill route cannot require skill references")
        limits = case.get("limits", {})
        if not isinstance(limits, dict) or any(
            key not in COUNT_FIELDS or type(value) is not int or value < 0
            for key, value in limits.items()
        ):
            errors.append(f"{case_id}: invalid operation limits")
    return errors


def valid_references(refs: object) -> bool:
    """Canonical repo-relative paths only, so spelling cannot evade budgets."""
    return isinstance(refs, list) and all(
        isinstance(ref, str) and ref.startswith(".codex/skills/")
        and "/references/" in ref and ".." not in Path(ref).parts
        and Path(ref).as_posix() == ref and (ROOT / ref).is_file()
        for ref in refs
    )


def validate_reference_links(path: Path) -> list[str]:
    """Check conditional links inside references as well as primary skills."""
    text = path.read_text(encoding="utf-8")
    errors: list[str] = []
    for ref in re.findall(r"`([^`\n]+)`", text):
        if any(char in ref for char in " *{}[]<>"):
            continue
        if ref.startswith(".codex/skills/"):
            target = ROOT / ref
        elif ref.startswith("../"):
            target = path.parent / ref
        elif ref.startswith(("references/", "scripts/", "assets/")):
            owner = path.parent.parent if path.parent.name == "references" else path.parent
            target = owner / ref
        elif ("/" not in ref and ref.endswith(".md") and path.parent.name == "references"
              and ref not in {"SKILL.md", "AGENTS.md", "CLAUDE.md"}):
            target = path.parent / ref
        else:
            continue
        if not target.exists():
            errors.append(f"{path}: missing conditional reference {ref}")
    return errors


def validate_observations(payload: object, cases: list[dict], names: set[str]) -> tuple[list[str], int]:
    """Check recorded runs, not synthesized routing guesses; evidence is reviewed separately."""
    if not isinstance(payload, dict) or not isinstance(payload.get("runs"), list) or not payload["runs"]:
        return ["observations require a non-empty runs list"], 0
    expected = {case["id"]: case for case in cases}
    errors: list[str] = []
    covered: set[str] = set()
    run_ids: set[str] = set()
    for run in payload["runs"]:
        if not isinstance(run, dict):
            errors.append("observation must be an object")
            continue
        case_id = run.get("case_id")
        if not isinstance(case_id, str) or case_id not in expected:
            errors.append(f"unknown observed case {case_id}")
            continue
        case = expected[case_id]
        covered.add(case_id)
        for field in ("run_id", "model", "revision", "evidence"):
            if not isinstance(run.get(field), str) or not run[field].strip():
                errors.append(f"{case_id}: missing provenance field {field}")
        run_id = run.get("run_id")
        if isinstance(run_id, str):
            if run_id in run_ids:
                errors.append(f"{case_id}: duplicate run_id {run_id}")
            run_ids.add(run_id)
        primary = run.get("primary")
        if "primary" not in run or primary != case["expected"]:
            errors.append(f"{case_id}: primary {primary}, expected {case['expected']}")
        if "expected_mode" in case and run.get("mode") != case["expected_mode"]:
            errors.append(f"{case_id}: mode {run.get('mode')}, expected {case['expected_mode']}")
        if primary is None and run.get("mode") is not None:
            errors.append(f"{case_id}: no-skill route must not select a mode")
        loaded = run.get("loaded_skills")
        if not isinstance(loaded, list) or any(
            not isinstance(name, str) or name not in names for name in loaded
        ):
            errors.append(f"{case_id}: invalid loaded_skills")
        else:
            if primary is None and loaded:
                errors.append(f"{case_id}: no-skill route loaded skills")
            elif primary is not None and primary not in loaded:
                errors.append(f"{case_id}: primary was not loaded")
            extra = set(loaded) & set(case.get("forbidden_skills", []))
            if extra:
                errors.append(f"{case_id}: forbidden skills loaded: {', '.join(sorted(extra))}")
        refs = run.get("loaded_references")
        if not valid_references(refs):
            errors.append(f"{case_id}: invalid or missing loaded_references")
        else:
            if primary is None and refs:
                errors.append(f"{case_id}: no-skill route loaded skill references")
            missing = set(case.get("required_references", [])) - set(refs)
            extra_refs = set(case.get("forbidden_references", [])) & set(refs)
            if missing:
                errors.append(f"{case_id}: required references not loaded: {', '.join(sorted(missing))}")
            if extra_refs:
                errors.append(f"{case_id}: forbidden references loaded: {', '.join(sorted(extra_refs))}")
        counts = run.get("counts")
        if not isinstance(counts, dict) or set(counts) != COUNT_FIELDS or any(
            type(value) is not int or value < 0 for value in counts.values()
        ):
            errors.append(f"{case_id}: counts must contain all four non-negative integer counters")
        else:
            for field, limit in case.get("limits", {}).items():
                if counts[field] > limit:
                    errors.append(f"{case_id}: {field}={counts[field]} exceeds {limit}")
        timings = run.get("timings_seconds")
        if not isinstance(timings, dict) or not {"total", "mcp", "build"} <= timings.keys():
            errors.append(f"{case_id}: timings_seconds requires total, mcp, build")
        elif any(
            type(value) not in {int, float} or not math.isfinite(value) or value < 0
            for value in timings.values()
        ):
            errors.append(f"{case_id}: timings must be finite non-negative seconds")
        elif any(value > timings["total"] for value in timings.values()):
            errors.append(f"{case_id}: a phase exceeds total elapsed time")
    return errors, len(covered)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--observations", type=Path, help="Check recorded agent runs against routing cases")
    parser.add_argument("--self-test", action="store_true", help="Run synthetic checker regression tests, not agent evals")
    args = parser.parse_args()
    if args.self_test:
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(RoutingObservationTests)
        return 0 if unittest.TextTestRunner(verbosity=1).run(suite).wasSuccessful() else 1
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
        if skill_dir.name.startswith("baseswiftui-") and (skill_dir / "SKILL.md").exists():
            skill_text = (skill_dir / "SKILL.md").read_text(encoding="utf-8")
            project_description_words += len(
                frontmatter(skill_text).get("description", "").split()
            )
            for doc in skill_dir.rglob("*.md"):
                errors.extend(validate_reference_links(doc))

    if names != EXPECTED_SKILLS:
        errors.append(f"expected nine entry points; missing={sorted(EXPECTED_SKILLS - names)}, unexpected={sorted(names - EXPECTED_SKILLS)}")

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
        "another project skill, tests, simulator",
        "build the workspace once for `generic/platform=iOS`",
        "word `compare` alone does not grant it",
        "above 844pt uses a screen-level `ScrollView`",
        "844pt or below uses no screen-level `ScrollView`",
        "`screen`: one screen plus existing-pattern Container/items/route/Factory",
    ):
        if required not in figma_normalized:
            errors.append(f"{figma_skill}: missing fast-path contract '{required}'")

    visual_reference = (
        SKILLS_ROOT / "baseswiftui-figma-ui" / "references" /
        "visual-validation.md"
    )
    visual_text = re.sub(
        r"\s+", " ", visual_reference.read_text(encoding="utf-8")
    )
    if "unless the user explicitly requests Simulator validation" not in visual_text:
        errors.append(
            f"{visual_reference}: Simulator validation must require explicit request"
        )

    if project_description_words > MAX_PROJECT_DESCRIPTION_WORDS:
        errors.append(
            f"BaseSwiftUI descriptions: {project_description_words} words "
            f"exceeds budget {MAX_PROJECT_DESCRIPTION_WORDS}"
        )

    try:
        cases = json.loads(CASES_PATH.read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        print(f"routing cases: {error}", file=sys.stderr)
        return 1
    case_errors = validate_cases(cases, names)
    errors.extend(case_errors)
    observed_count = 0
    if args.observations and not case_errors:
        try:
            payload = json.loads(args.observations.read_text(encoding="utf-8"))
            observation_errors, observed_count = validate_observations(payload, cases, names)
            errors.extend(observation_errors)
        except (OSError, ValueError) as error:
            errors.append(f"observations: {error}")

    if errors:
        print("agent setup validation: FAILED")
        for error in errors:
            print(f"- {error}")
        return 1
    print(
        "agent setup validation: OK "
        f"({len(names)} skills, {len(cases)} routing case definitions, "
        f"{project_description_words} description words, "
        f"{bootstrap_words} bootstrap words)"
    )
    if args.observations:
        print(f"recorded observations checked: {observed_count}/{len(cases)} cases; review linked evidence separately")
    else:
        print("behavioral routing and latency: NOT RUN (use --observations with actual session records)")
    return 0


class RoutingObservationTests(unittest.TestCase):
    """Synthetic checker tests; these are not agent routing observations."""
    def setUp(self):
        self.names = EXPECTED_SKILLS
        self.cases = [{
            "id": "screen", "prompt": "Build one screen with existing route wiring",
            "expected": "baseswiftui-figma-ui", "expected_mode": "screen",
            "forbidden_skills": ["baseswiftui-architecture"],
            "limits": {"builds": 1, "design_context_calls": 1},
        }]
        self.run = {
            "case_id": "screen", "run_id": "synthetic-1", "model": "test-fixture",
            "revision": "test-fixture", "evidence": "synthetic record; not a real session",
            "primary": "baseswiftui-figma-ui", "mode": "screen",
            "loaded_skills": ["baseswiftui-figma-ui"],
            "loaded_references": [],
            "counts": {"builds": 1, "design_context_calls": 1, "edits": 3, "index_refreshes": 1},
            "timings_seconds": {"total": 60, "mcp": 10, "build": 20},
        }

    def check(self, run=None):
        return validate_observations({"runs": [self.run if run is None else run]}, self.cases, self.names)[0]

    def test_screen_can_edit_multiple_files_and_check_shared_impact(self):
        self.assertEqual(validate_cases(self.cases, self.names), [])
        self.assertEqual(self.check(), [])

    def test_wrong_owner_and_scope_are_reported(self):
        self.run.update(primary="baseswiftui-architecture", mode="flow")
        errors = self.check()
        self.assertTrue(any("primary" in error for error in errors))
        self.assertTrue(any("mode" in error for error in errors))

    def test_correct_primary_does_not_hide_unnecessary_companion(self):
        self.run["loaded_skills"].append("baseswiftui-architecture")
        self.assertTrue(any("forbidden skills" in error for error in self.check()))

    def test_extra_mcp_and_build_calls_fail_budget(self):
        self.run["counts"].update(builds=2, design_context_calls=2)
        errors = self.check()
        self.assertTrue(any("builds=2" in error for error in errors))
        self.assertTrue(any("design_context_calls=2" in error for error in errors))

    def test_read_only_case_rejects_edits_builds_and_indexing(self):
        self.cases[0]["limits"] = {"edits": 0, "builds": 0, "index_refreshes": 0}
        errors = self.check()
        for counter in ("edits", "builds", "index_refreshes"):
            self.assertTrue(any(f"{counter}=" in error for error in errors))

    def test_missing_counts_and_provenance_do_not_pass(self):
        del self.run["counts"]["edits"]
        del self.run["evidence"]
        errors = self.check()
        self.assertTrue(any("counts" in error for error in errors))
        self.assertTrue(any("evidence" in error for error in errors))

    def test_unknown_and_duplicate_runs_do_not_inflate_coverage(self):
        errors, covered = validate_observations({"runs": [self.run, self.run]}, self.cases, self.names)
        self.assertEqual(covered, 1)
        self.assertTrue(any("duplicate run_id" in error for error in errors))
        self.run["case_id"] = "unknown"
        self.assertTrue(any("unknown observed case" in error for error in self.check()))

    def test_partial_coverage_is_counted_not_assumed(self):
        other = copy.deepcopy(self.cases[0])
        other["id"] = "second-case"
        errors, covered = validate_observations({"runs": [self.run]}, self.cases + [other], self.names)
        self.assertEqual(errors, [])
        self.assertEqual(covered, 1)

    def test_impossible_or_non_numeric_timings_fail(self):
        for value in (-1, float("nan"), float("inf"), True, "20", 61):
            with self.subTest(value=value):
                self.run["timings_seconds"]["mcp"] = value
                self.assertTrue(self.check())

    def test_mode_must_belong_to_primary_and_primary_cannot_be_forbidden(self):
        self.cases[0]["expected"] = "baseswiftui-architecture"
        errors = validate_cases(self.cases, self.names)
        self.assertTrue(any("invalid mode" in error for error in errors))
        self.assertTrue(any("cannot be forbidden" in error for error in errors))

    def test_malformed_records_fail_with_diagnostics(self):
        for payload in (None, [], {}, {"runs": []}, {"runs": [None]}):
            with self.subTest(payload=payload):
                self.assertTrue(validate_observations(payload, self.cases, self.names)[0])
        for cases in (None, [], [None], [{"id": []}], [{"id": "bad", "expected": []}]):
            with self.subTest(cases=cases):
                self.assertTrue(validate_cases(cases, self.names))

    def test_no_skill_question_is_explicit_and_read_only(self):
        self.cases[0].update(expected=None, limits={"edits": 0, "builds": 0, "index_refreshes": 0})
        self.cases[0].pop("expected_mode")
        self.run.update(primary=None, mode=None, loaded_skills=[], counts=dict.fromkeys(COUNT_FIELDS, 0))
        self.assertEqual(validate_cases(self.cases, self.names), [])
        self.assertEqual(self.check(), [])
        self.run["loaded_skills"] = ["baseswiftui-swiftui-review"]
        self.assertTrue(any("no-skill" in error for error in self.check()))
        self.run["loaded_skills"] = []
        del self.run["primary"]
        self.assertTrue(any("primary" in error for error in self.check()))

    def test_no_skill_cannot_hide_reference_loading(self):
        self.cases[0].update(expected=None)
        self.cases[0].pop("expected_mode")
        self.run.update(primary=None, mode=None, loaded_skills=[], loaded_references=[
            ".codex/skills/baseswiftui-architecture/references/ios-guidelines.md"
        ])
        self.assertTrue(any("no-skill route loaded skill references" in error for error in self.check()))

    def test_quality_mode_requires_its_reference(self):
        ref = ".codex/skills/baseswiftui-swiftui-review/references/testing-debugging.md"
        self.cases[0].update(expected="baseswiftui-swiftui-review", expected_mode="debug", required_references=[ref])
        self.run.update(primary="baseswiftui-swiftui-review", mode="debug", loaded_skills=["baseswiftui-swiftui-review"])
        self.assertEqual(validate_cases(self.cases, self.names), [])
        self.assertTrue(any("required references" in error for error in self.check()))
        self.run["loaded_references"] = [ref]
        self.assertEqual(self.check(), [])

    def test_irrelevant_reference_fails_even_with_correct_primary(self):
        ref = ".codex/skills/baseswiftui-swiftui-review/references/performance-trace.md"
        self.cases[0]["forbidden_references"] = [ref]
        self.run["loaded_references"] = [ref]
        self.assertTrue(any("forbidden references" in error for error in self.check()))

    def test_broken_ambiguous_or_missing_references_fail(self):
        ref = ".codex/skills/baseswiftui-swiftui-review/references/testing-debugging.md"
        for refs in (None, "text", [None], [ref.replace("testing-debugging", "missing")], [ref.replace("references/", "references/../references/")]):
            with self.subTest(refs=refs):
                self.cases[0]["required_references"] = refs
                self.assertTrue(validate_cases(self.cases, self.names))
                self.run["loaded_references"] = refs
                self.assertTrue(self.check())
        self.cases[0].update(required_references=[ref], forbidden_references=[ref])
        self.assertTrue(any("cannot be forbidden" in error for error in validate_cases(self.cases, self.names)))

    def test_all_quality_modes_are_valid_but_unknown_mode_fails(self):
        self.cases[0]["expected"] = "baseswiftui-swiftui-review"
        for mode in ("source", "debug", "test", "api", "trace"):
            self.cases[0]["expected_mode"] = mode
            self.assertEqual(validate_cases(self.cases, self.names), [])
        self.cases[0]["expected_mode"] = "everything"
        self.assertTrue(validate_cases(self.cases, self.names))


if __name__ == "__main__":
    raise SystemExit(main())
