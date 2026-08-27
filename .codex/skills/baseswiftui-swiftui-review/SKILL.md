---
name: baseswiftui-swiftui-review
description: Review BaseSwiftUI source for correctness, state, identity, navigation, performance, accessibility, localization, and API use. Use for quality/improvement audits; route traces, dedicated security audits, and API-baseline refreshes separately.
---

# BaseSwiftUI SwiftUI Review

Review the app against its real baseline: iOS 17, Swift 5, SwiftUI, Combine,
Factory, and the repository's MVI/router conventions. Recommend newer APIs only
when they are available to the current deployment target or explicitly guarded.

## Required context

1. Read `AI-Workflow/WORKFLOW_AI.md` and the nearest feature/base guide.
2. Read `references/review-checklist.md` for every review.
3. Read `references/modern-swiftui.md` when the review touches API choice,
   state, identity, navigation, layout, performance, or accessibility.
4. Read
   `../baseswiftui-swiftui-ui/references/interaction-content-patterns.md` when
   the review touches animation, focus, scrolling, images, localization,
   Charts, or previews.
5. Inspect the closest working feature before declaring a local pattern wrong.
6. Use GitNexus impact analysis before changing Swift symbols. A read-only
   review does not authorize fixes and does not require symbol impact analysis.

## Review order

1. Correctness: crashes, invalid state transitions, cancellation, routing and
   presentation ownership, race conditions, error handling, and data loss.
2. Security and privacy: credentials, token persistence, sensitive logging,
   unsafe URL/config handling, and secret exposure.
3. State and architecture: single source of truth, correct property-wrapper
   ownership, render-only Views, MVI intent flow, Factory wiring, and layer
   boundaries.
4. Collections and identity: stable unique IDs, correct filtering/index paths,
   BaseDataSource ownership, and deterministic row structure.
5. User experience: Dynamic Type, VoiceOver labels/traits, touch targets,
   localization, safe areas, compact width, loading, empty, and error states.
6. Performance: repeated work in `body`, unnecessary observation, expensive
   type erasure, image sizing, lazy containers, and animation scope.
7. API hygiene: deprecated or legacy APIs that have a clear iOS 17 replacement.

Do not report project base-component internals as feature violations merely
because those reusable components contain `ForEach`, `GeometryReader`,
`onTapGesture`, or justified `AnyView`. Review whether feature code uses the
Base abstraction correctly.

## Compatibility rules

- Preserve existing `ObservableObject`, `@Published`, `@StateObject`,
  `@ObservedObject`, and Combine flows unless an Observation migration is the
  explicit task.
- Do not require Swift 6 concurrency or `Sendable` rules for this Swift 5
  project. Report concrete race or isolation problems with evidence.
- Do not recommend iOS 18+ or iOS 26-only APIs without an availability guard or
  an explicit deployment-target change.
- Prefer a small, local fix that matches neighboring code over a broad style
  rewrite.

## Findings format

Lead with findings, ordered by severity: `Critical`, `High`, `Medium`, then
`Low`. For each finding include the file and line, the observable failure or
risk, evidence from the code path, and the smallest safe remediation. Separate
confirmed defects from optional improvements. If no material finding exists,
say so and list any validation gaps.

When the user asks for improvements but not implementation, stop after the
evidence-backed report. When fixes are explicitly requested, run impact
analysis first, apply only accepted/in-scope fixes, then build through
`BaseSwiftUI.xcworkspace`.

Route a dedicated `.trace` capture/analysis to
`baseswiftui-performance-trace`, a dedicated security/privacy audit to
`baseswiftui-security-review`, and a version-baseline refresh to
`baseswiftui-api-maintenance` instead of expanding this general review skill.
