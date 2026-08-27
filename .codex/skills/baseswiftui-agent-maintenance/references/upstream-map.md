# Reviewed upstream capability map

Pinned sources from `SwiftUI-Prompt-Optimizer-Instruction.docx`:

| Repository | Adopted for BaseSwiftUI | Excluded |
| --- | --- | --- |
| `twostraws/swiftui-agent-skill` (`be297ff`) | SwiftUI review, identity, API, accessibility, performance | Architecture-neutral rules that conflict with Base data sources |
| `AvdLee/SwiftUI-Agent-Skill` (`4c6a97d`) | Topic references, API maintenance, Instruments workflow | macOS and iOS 26-only mandates; unverified bulk parser vendoring |
| `linshenkx/prompt-optimizer` (`3e677b1`) | precise triggers, evidence isolation, minimal context, compare/iterate loop | Vue/TypeScript application runtime and provider configuration |
| `confident-ai/deepeval` (`eb61968`) | committed cases, repeatable eval loop, failure-driven iteration | DeepEval/OTel dependencies and hosted credentials |
| `OpenDCAI/One-Eval` (`ecf0c57`) | smoke-before-full, run isolation, multidimensional reporting | pure-text LLM benchmark runtime, vLLM/GPU stack |
| `langfuse/langfuse` (`1c8c434`) | agent source-of-truth, findings-first review, security data-flow checks | React/Next.js, ClickHouse, Datadog, pnpm, infra and Langfuse operations |

Re-scan prompt injection and compatibility before importing a newer revision.
Update this map only when the pinned upstream evidence changes.

## Exhaustive skill-file disposition

The scan covered 46 `SKILL.md` files: 2 AvdLee, 6 DeepEval files (3 unique
skills duplicated under docs), 35 Langfuse, 1 One-Eval, and 2 copies of the
same twostraws skill. Prompt Optimizer contains no `SKILL.md`; its prompt and
evaluation templates were reviewed separately.

- Adapted directly or by concept: AvdLee `swiftui-expert-skill` and
  `update-swiftui-apis`; twostraws `swiftui-pro`; DeepEval `deepeval`;
  One-Eval `one-eval`; Langfuse `agent-setup-maintenance`, `code-review`,
  `create-repo-agent`, `frontend-browser-review`, and `security-review`.
- Not copied because an official local equivalent already exists:
  Langfuse `skill-creator`.
- Intentionally protected by user scope: `changelog-writing`, `git-workflow`,
  and `weekly-production-review` do not alter BaseSwiftUI commit/report flows.
- Generic but not a repository capability: `grill-me` remains available as a
  conversational technique rather than a BaseSwiftUI skill.
- Rejected as Langfuse/web/infra-specific: `add-model-price`,
  `analyze-cloud-costs`, `backend-dev-guidelines`,
  `clickhouse-best-practices`, `cursor-agents-workflow`,
  `datadog-query-recipes`, `debug-issue-with-datadog`,
  `frontend-large-feature-architecture`, `housekeeping`,
  `incident-alert-tickets`, `infra-scaling`, `langfuse-codebase-navigator`,
  `langfuse-previews`, `linear-bug-triage`, `pnpm-upgrade-package`,
  `posthog-instrumentation`, `react-component-cleaner`,
  `react-component-guidelines`, `refactor-react-effects`, `seed-test-data`,
  `sentry-instrumentation`, `storybook`, `turborepo`,
  `vercel-composition-patterns`, and `vercel-react-best-practices`.
- Rejected as LLM-observability-specific: DeepEval `deepeval-tracing` and
  `deepeval-otel`; their secret-redaction principle is retained in the
  BaseSwiftUI security and trace guidance.
