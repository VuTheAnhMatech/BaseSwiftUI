---
name: baseswiftui-swiftui-review
description: Review, debug, or test BaseSwiftUI; inspect source performance, analyze/record Instruments traces, or refresh SDK/API guidance. Use for diagnosis and quality work; simple explanations need no skill. Dedicated security audits use security-review.
---

# BaseSwiftUI Quality and Debugging

Preserve iOS 17, Swift 5, MVI, Combine/ObservableObject, Factory, CocoaPods,
and the workspace. Select one mode from the requested outcome, not keywords.

## Conditional modes

- `source`: correctness, state, navigation, accessibility, localization, or
  source-only performance review → read `references/source-review.md` and
  `references/review-checklist.md`. Read `references/modern-swiftui.md` only
  for the topics named by the source-review procedure.
- `debug`: a concrete bug/regression → read `references/testing-debugging.md`;
  localize the cause before an authorized fix.
- `test`: test design, implementation, or gaps → read
  `references/testing-debugging.md`; use existing targets and meaningful
  behavior checks.
- `api`: explicit SDK/deprecation-baseline audit or refresh → read
  `references/api-maintenance.md` and `references/api-baseline.md`; read
  `references/scan-manifest.md` for the affected topic/SDK refresh.
  Run `scripts/scan_swiftui_api_usage.py` only as that procedure directs.
- `trace`: explicit Instruments capture or existing `.trace` analysis → read
  `references/performance-trace.md`, then `references/recording.md` only for
  capture, or `references/analysis.md` for recorded evidence.

Do not preload other modes. A slow-screen bug starts with `debug` unless the
user requests a source audit or trace. If evidence requires another mode, read
only its relevant reference and retain this primary skill. Do not load the
full source checklist for a focused debug, test, API, or trace task.

## Quality boundaries

- Explanations of code or Swift concepts need no skill; inspect only relevant
  source. A requested diagnosis/audit uses its mode even if read-only.
- Reviews, diagnosis-only requests, test plans, and trace analysis do not
  authorize edits. Implement fixes/tests only within the requested scope.
- Before shared Swift edits, follow root impact rules. After Swift edits,
  run focused relevant tests when available and one `generic/platform=iOS`
  workspace build; repeat after changes. Simulator needs explicit request.
- Preserve availability guards and state/presentation ownership. Compile
  success is not evidence of runtime behavior, accessibility, or visual QA.
- Report findings by severity with file/line or trace time, supporting
  evidence, smallest remediation, and verification gaps. Never call a scan
  candidate a confirmed deprecation or a source hypothesis a measured hitch.
- Dedicated security/privacy audits use `baseswiftui-security-review`.
  IAP/paywall implementation stays with `baseswiftui-iap-flow`; ordinary new
  UI and architectural redesign stay with their implementation owners.
