# Agent maintenance contract

## Ownership

- Root `AGENTS.md` and `CLAUDE.md`: bootstrap, safety, and routing only.
- `AI-Workflow/WORKFLOW_AI.md`: repository workflow branches and compliance
  gates.
- `AI-Workflow/AGENTS.md`: mandatory preflight and execution policy.
- `.codex/skills/<name>/SKILL.md`: trigger plus essential procedure.
- `references/`: conditional domain detail; `scripts/`: deterministic repeated
  work; `agents/openai.yaml`: user-facing metadata.

## Merge rules

- Enhance an existing skill when the same user prompt should trigger it.
- Create a skill only when it has a distinct intent, workflow, and validation
  path.
- Prefer a single canonical rule with links from consumers. Repeat a one-line
  safety invariant only when it must remain visible without loading another
  file.
- Keep SKILL bodies under 500 lines and references one level from SKILL.md.
- Preserve exact project names, paths, deployment target, and architecture.
- Keep provider metadata synchronized: folder name = frontmatter name and
  `default_prompt` must mention `$skill-name`.

## Review gates

- Every new description states what the skill does and when it triggers.
- Overlapping skills state a negative boundary or a router precedence rule.
- Every referenced local path exists.
- External commands, services, MCPs, credentials, and dependencies are either
  available or explicitly optional with a fallback.
- Existing working behavior remains reachable after routing changes.
