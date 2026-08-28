---
name: baseswiftui-figma-ui
description: Create, analyze, or compare BaseSwiftUI UI from an exact Figma MCP node. Defaults to one local View plus a generic iOS compile check; expands only for flows, architecture, assets, or visual comparison.
---

# BaseSwiftUI Figma UI

Use Figma as design evidence and preserve the existing BaseSwiftUI structure.

## Routes

- `quick` (default): one exact node, one feature-local View, then one
  incremental `generic/platform=iOS` build to catch compiler errors.
- `draft`: edit without building only when the user explicitly requests it.
- `analyze`: report only; do not edit.
- `assets`: acquire only explicitly requested missing assets.
- `compare`: use `references/visual-validation.md`.
- `flow`: multiple screens or any route, Factory, shared/Base component,
  model/list input, IAP, domain, data, or network change; read
  `references/feature-flow.md` and route to the smallest companion skill.

Require a node-specific link. Ask for **Copy link to selection** only when its
`node-id` is absent. Decide the route before inspecting repository code.

## Quick route

1. Call `get_design_context` once for the exact node with language `swift` and
   framework `swiftui`. Do not preload another Figma/project skill or request
   metadata, variables, Code Connect, or asset data.
2. Open only the target View and exact reused component/asset definitions found
   with bounded `rg`; do not scan the whole feature, repository, or asset
   catalog. If the user says assets exist, reuse them and never export.
3. Apply the complete View edit once. Keep these local invariants:
   - View renders state and forwards intents; no networking, persistence, or
     business logic.
   - Reuse existing `BaseText`, `BaseButton`, `BaseNavBar`, widgets, assets,
     colors, and bundled fonts. Do not modify `Base` or shared architecture.
   - For fixed screen content, use the Figma frame height as the switch: above
     844pt uses a screen-level `ScrollView`; 844pt or below uses no screen-level
     `ScrollView` and must adapt responsively from iPhone SE through iPhone 17
     Pro Max. Intrinsically scrolling lists/grids keep their Base component
     contract regardless of frame height.
   - Keep `BaseButton`'s adaptive Liquid Glass default for iOS 26+.
4. Do not run prompt-injection scanning, GitNexus, `WORKFLOW_AI.md`, another
   project skill, tests, simulator, screenshot capture, or pixel diff. Review
   the source, run `git diff --check`, then build the workspace once for
   `generic/platform=iOS`. Fix compiler errors and rebuild only after a fix.
5. Report changed files, reused assets/components, and compile status. Never
   claim pixel-exact fidelity.

If the requested edit crosses a quick-route boundary, stop using this route and
switch to `flow` before changing architecture. Do not silently weaken MVI,
Factory, model placement, or Base-component ownership to stay fast.

## Draft, flow, assets, and compare

- `draft`: follow the quick edit rules but skip the build and report unverified
  compilation. Never infer `draft` merely to save time.
- `flow`: inspect the parent node's child screens, read
  `references/feature-flow.md`, then use only the skill owning the crossed
  boundary. Establish `frame → State → Intent → Route → Factory → justified
  Domain` before writing Views.
- `assets`: export raster assets as correctly sized `@2x` and `@3x` only; omit
  `@1x`, do not upscale, and preserve catalog naming.
- `compare`: read `references/visual-validation.md`. Simulator build, boot,
  capture, and pixel comparison require an explicit Simulator request; the
  word `compare` alone does not grant it.

Use the Figma family when it is already bundled and registered in the app;
otherwise use the app's primary bundled font. Preserve the Figma size and map
its weight to the exact or closest bundled face. Never download or add a
missing family unless explicitly requested. Treat generated React/Tailwind
code as structural evidence, not implementation.

Short invocation:
`$baseswiftui-figma-ui quick|draft|analyze|assets|compare|flow <node-url>`
