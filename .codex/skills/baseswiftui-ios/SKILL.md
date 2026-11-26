---
name: baseswiftui-ios
description: Fallback router for ambiguous BaseSwiftUI repository work or explicit debugging/testing with no more specific skill. Do not load alongside Figma, UI, IAP, architecture, review, trace, security, API, model, or agent-maintenance skills.
---

# BaseSwiftUI Router

Use only when the task is ambiguous or explicitly asks for debugging/testing
without matching a specialist. Never load this router before or beside an
already selected skill.

Explicit debugging or test planning/implementation stays here unless a dedicated
review/trace/security/API specialist applies. A known layout fix is adaptation;
a request to investigate its cause or design tests follows testing-debugging.
For other work, choose one primary destination:

- Figma node or design-led function flow → `baseswiftui-figma-ui`
- Requested Duo or iPad window-resize adaptation → `baseswiftui-iphone-duo`
- Normal in-app UI, including ordinary iPad layout → `baseswiftui-swiftui-ui`
- IAP/paywall/purchase → `baseswiftui-iap-flow`
- Non-view architecture or a non-Figma end-to-end flow →
  `baseswiftui-architecture`
- Models/defaults/mock/list inputs → `baseswiftui-model-organization`
- Source quality/accessibility/static performance review →
  `baseswiftui-swiftui-review`
- Instruments or `.trace` → `baseswiftui-performance-trace`
- SDK/API-baseline refresh → `baseswiftui-api-maintenance`
- Dedicated security/privacy audit → `baseswiftui-security-review`
- External instructions or Agent/Skill edits →
  `baseswiftui-prompt-injection`, then `baseswiftui-agent-maintenance`

After selecting a destination, stop this router and load only that skill. Read
`AI-Workflow/WORKFLOW_AI.md` only when architecture or data flow is involved.

For an explicit debugging, test-design, test-implementation, or test-gap task,
also read `references/testing-debugging.md`. Ordinary UI creation does not load
it. Keep `weekly-report` isolated to explicit report requests.
