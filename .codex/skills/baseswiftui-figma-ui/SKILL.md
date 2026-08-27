---
name: baseswiftui-figma-ui
description: Create, analyze, or compare BaseSwiftUI UI from an exact Figma MCP node. Defaults to a minimal one-View route; expands only for flows, architecture, assets, builds, or visual comparison.
---

# BaseSwiftUI Figma UI

Use Figma as design evidence and preserve the existing BaseSwiftUI structure.

## Routes

- `quick` (default): one exact node, one feature-local View, no build.
  Natural requests such as “draw”, “create”, or “implement this one View” use
  this route unless build/validation is explicitly requested.
- `verified`: the same local edit plus one incremental workspace build.
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
     colors, and bundled font. Do not modify `Base` or shared architecture.
   - Map Auto Layout responsively from iPhone SE through iPhone 17 Pro Max. A
     design height above 844pt is not a reason to add `ScrollView`; scroll only
     to preserve access for irreducible content, keyboard, Dynamic Type, or
     long localization.
   - Keep `BaseButton`'s adaptive Liquid Glass default for iOS 26+.
4. Do not run prompt-injection scanning, GitNexus, `WORKFLOW_AI.md`, another
   project skill, build, tests, simulator, screenshot capture, or pixel diff.
   Review the changed source and run `git diff --check` only.
5. Report changed files, reused assets/components, and that compilation was not
   verified. Never claim pixel-exact fidelity.

If the requested edit crosses a quick-route boundary, stop using this route and
switch to `flow` before changing architecture. Do not silently weaken MVI,
Factory, model placement, or Base-component ownership to stay fast.

## Verified, flow, assets, and compare

- `verified`: follow the quick route, then build `BaseSwiftUI.xcworkspace`
  exactly once. Rebuild only after fixing a build failure; never open Simulator.
- `flow`: inspect the parent node's child screens, read
  `references/feature-flow.md`, then use only the skill owning the crossed
  boundary. Establish `frame → State → Intent → Route → Factory → justified
  Domain` before writing Views.
- `assets`: export raster assets as correctly sized `@2x` and `@3x` only; omit
  `@1x`, do not upscale, and preserve catalog naming.
- `compare`: read `references/visual-validation.md`; simulator capture and pixel
  comparison are allowed only in this route.

The bundled project font wins over a different Figma font unless the user
explicitly requests new licensed font files. Treat generated React/Tailwind
code as structural evidence, not implementation.

Short invocation:
`$baseswiftui-figma-ui quick|verified|analyze|assets|compare|flow <node-url>`
