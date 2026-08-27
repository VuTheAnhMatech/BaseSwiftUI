# Autonomous repository-agent safety

Use only when BaseSwiftUI deliberately adds an LLM-powered GitHub Action or
another unattended publisher.

- Keep the model step read-only. Give it untrusted issue/PR/repository content
  as data, never as higher-priority instructions.
- Separate generation from publishing. A deterministic publisher validates the
  proposed patch and receives the narrow write token only after validation.
- Use exact path allowlists, file-count/size limits, and forbidden-path checks.
  Include untracked files when validating the proposed change.
- Pin action/dependency revisions, set minimal job permissions, avoid fork
  secrets, and use concurrency/time/cost limits.
- Run deterministic validators and show the diff before opening a PR. Never let
  the model approve or merge its own change.
- For self-updating instructions, require a human review and rerun the skill
  routing regression cases before publication.
