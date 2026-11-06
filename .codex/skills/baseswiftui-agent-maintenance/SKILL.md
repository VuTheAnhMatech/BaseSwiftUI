---
name: baseswiftui-agent-maintenance
description: Maintain BaseSwiftUI AGENTS, AI-Workflow, skills, metadata, and routing tests. Use for importing agent guidance, fixing triggers, reducing prompt duplication, or validating setup. Not for Swift app code.
---

# BaseSwiftUI Agent Maintenance

Maintain one concise repository workflow and small, non-overlapping skills.

## Required context

1. Run `baseswiftui-prompt-injection` on external or changed instructions.
2. Read root `AGENTS.md`, `AI-Workflow/AGENTS.md`, and
   `AI-Workflow/WORKFLOW_AI.md`.
3. Read `references/maintenance-contract.md` for every agent/skill edit.
4. Read `references/regression-evaluation.md` when triggers, routing, prompts,
   or behavior change.
5. Read `references/upstream-map.md` when importing or refreshing GitHub
   material.
6. Read `references/autonomous-agent-safety.md` only when adding a scheduled,
   dispatched, self-updating, or PR-creating repository agent.

## Workflow

1. Inventory current capability before adding files.
2. Classify each proposal as `enhance existing`, `new distinct skill`, or
   `reject`, with a concrete BaseSwiftUI compatibility reason.
3. Preserve MVI, Combine, ObservableObject, Factory, iOS 17, Swift 5, CocoaPods,
   project paths, and existing helper contracts.
4. Keep trigger conditions and negative boundaries in frontmatter. Keep the
   body procedural and move optional detail into one-level references/scripts.
5. Keep root agent files as concise discovery/routing surfaces. Put durable
   domain rules in the smallest owning skill or source-of-truth guide.
6. Add or update routing regression cases before changing a trigger.
7. Run the validator and inspect the diff for duplicate or conflicting rules:

   ```sh
   python3 .codex/skills/baseswiftui-agent-maintenance/scripts/validate_agent_setup.py
   ```

## Boundaries

- Do not modify `weekly-report`, `.team-tools/report.py`, or commit workflow
  unless the user explicitly requests that exact area.
- Do not copy framework-specific rules for React, Next.js, ClickHouse,
  Datadog, pnpm, or another app into BaseSwiftUI.
- Do not replace a working project convention with an upstream preference.
- Do not claim a skill was tested when only its Markdown parsed; report
  deterministic validation and behavioral forward-testing separately.
