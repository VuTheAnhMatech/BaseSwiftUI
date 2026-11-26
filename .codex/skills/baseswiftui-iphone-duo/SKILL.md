---
name: baseswiftui-iphone-duo
description: Implement or assess iPhone Duo (Dou) adaptation and iPad window resizing in BaseSwiftUI with shared views and stable state. Excludes ordinary UI, in-content drag gestures, exact Figma nodes, paywalls, shared architecture redesign and general SDK audits.
---

# BaseSwiftUI Duo and iPad Adaptive UI

Use `adapt` for requested UI implementation/fixes and `assess` for read-only
Duo/iPad window-layout advice or readiness checks. Keep the existing skill name
for compatibility. A device mention alone does not turn an ordinary UI edit into
adaptation. Simple code explanations need no skill. Resizing an image/canvas
with an app gesture is ordinary UI unless window/fold adaptation is also requested.

## Scope and evidence

1. Inspect the target View, its Container/state owner and reused components.
   For a new screen, inspect one nearest feature. Expand only for a concrete
   uncertainty or shared contract; do not audit the app by default.
2. Identify the content relationship and state that must survive resizing.
   Read the matching sections of the shared
   `.codex/skills/baseswiftui-swiftui-ui/references/adaptive-windows.md` for iPad
   window resizing or a shared iPhone/iPad/Duo screen. Use one screen composition
   and state owner, with small child Views and layout choices as needed.
   For Duo/pane patterns, read the matching section of `references/layout-patterns.md`.
   iPad-only adaptation does not require fold APIs or a Duo SDK sweep.
   For bars, overflow or sheet placement, read `references/bars-and-presentations.md`.
   For pane reflow, focus or accessibility changes, read `references/accessibility.md`.
3. Before adding a Duo-only symbol, read `references/sdk-compatibility.md`;
   verify the selected SDK and current Apple declaration. Reuse unchanged
   evidence. Ordinary iOS 17 layout work does not need a full SDK scan.
4. Keep one primary skill: exact-node work uses Figma, paywalls use IAP,
   shared architecture redesign uses architecture, reviews use swiftui-review,
   debug/tests use ios, SDK audits use api-maintenance and traces use performance-trace. Those owners may read the relevant Duo reference
   without loading this workflow. Camera capture/dual-display pipelines are
   outside this UI skill; scope their architecture and permissions separately.

## Adapt within the base

- Preserve iOS 17, Swift 5, MVI, Combine/ObservableObject, Factory, CocoaPods
  and the workspace. Upstream Observation/new-project templates are not the
  app architecture. Keep the ProjMaker-based Core/Presentation/Domain/Data/Utils
  structure and existing Network, DataSource and shared UI layers. Do not add
  packages or change deployment target, language mode or project toolchain settings.
- Adapt to the live content proposal while iPad's system window frame is dragged.
  Do not implement a root resize gesture, copy the launch size, or wait until
  dragging ends to update ordinary layout. Size class alone may not change.
- Keep the Container and BaseDataSource at stable owners above changing
  layouts. Views render state, forward intents and handle Effects through the
  Environment router; Containers do not own routers. Preserve IDs, selection,
  draft text, focus, scroll anchors and ongoing work across transitions.
- Reuse BaseText, BaseButton, existing colors/fonts/assets and Base renderers.
  Inspect BaseNavBar's actual contract before adapting bars; a custom HStack
  does not acquire system vertical-toolbar behavior automatically.
- For screen wiring/routes, read
  `.codex/skills/baseswiftui-swiftui-ui/references/navigation-ownership.md`.
  Keep the existing router and Factory construction. Root shared-symbol
  impact rules apply; file count alone does not escalate the task.
- Prefer a feature-local layout first. Reusable UI belongs in
  `BaseSwiftUI/Widgets` with a focused contract in its README, not a new
  shared Duo framework. Do not add a second navigation or data owner.
- Lay out from current container space and per-edge safe areas. Use reserved
  regions only where needed. Never identify Duo by a point-size threshold,
  assume the fold is at width/2, or drive layout from hinge-angle thresholds.

## Finish for the requested mode

Read `references/validation.md` for the changed behavior. `assess` makes no
edits, builds or index refreshes. `adapt` follows root impact/build rules;
fix compiler errors and rebuild after further Swift edits. Simulator requires
an explicit request. Do not run upstream installers, audit scripts, automatic
commits or whole-app pose sweeps.

Report the chosen pattern, state owner, older-OS behavior, actual build result
and remaining runtime gaps. No SDK support means no claim of Duo compilation;
no runtime check means no claim that state/visual continuity is proven.
For provenance or an API disagreement, read `references/sources.md`.

Invocation: `$baseswiftui-iphone-duo adapt|assess <Duo or iPad window-layout task>`.
