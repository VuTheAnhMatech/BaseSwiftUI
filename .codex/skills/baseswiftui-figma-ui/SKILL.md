---
name: baseswiftui-figma-ui
description: Implement high-fidelity BaseSwiftUI UI from an exact Figma MCP node with a fast one-View default, bounded evidence escalation, architecture preservation, and optional flow or visual comparison modes.
---

# BaseSwiftUI Figma UI

Use exact Figma evidence without changing BaseSwiftUI structure.

## Routes

- `quick` (default): one exact node, local View, fidelity gate, one generic build.
- `draft`: edit without building only when the user explicitly requests it.
- `analyze`: report only; do not edit.
- `assets`: asset-only inspection or acquisition for the selected node.
- `compare`: use `references/visual-validation.md`.
- `flow`: multiple screens or any route, Factory, shared/Base, model/list, IAP,
  domain, data, or network change; read `references/feature-flow.md`.

Require a node-specific link. Ask for **Copy link to selection** only when its
`node-id` is absent. Decide the route before inspecting repository code.

## Quick route

1. Call `get_design_context` once for the exact node with language `swift` and
   framework `swiftui`. Use its screenshot as visual truth. If absent or
   unreadable, request one exact-node screenshot; never request it speculatively.
2. Open only the target View and exact reused component/asset definitions via
   bounded `rg`. If the user says assets exist, reuse them and never export.
3. Classify `frame · spacing · type · effects · assets · safe area` as Figma
   evidence, project mapping, or unresolved; output no plan. Resolve only
   material unknowns with the specific evidence call needed. Load no generic
   Figma guideline resources.
4. Edit the View once while keeping these contracts:
   - Render state and forward intents; keep business logic, networking, and
     persistence outside Views. Reuse Base components, tokens, fonts, and assets.
     Do not modify `Base` or shared architecture for a local View.
   - Preserve explicit Figma icon, button, artwork, card-height, radius, spacing,
     typography, and effect values. Only Auto Layout stretch/fill regions become
     flexible. Compress flexible space first on small devices; never apply a
     whole-screen ratio, `scaleEffect`, or silent element resize.
   - Fixed content above 844pt uses a screen-level `ScrollView`; 844pt or below uses no screen-level `ScrollView` and adapts from iPhone SE through iPhone 17 Pro Max. Intrinsic Base lists/grids keep their scroll contract.
   - Only backgrounds may `ignoresSafeArea()`. Foreground anchors to dynamic
     iOS safe areas; never hard-code 44pt/34pt or branch by device. Treat system
     insets separately from design spacing, and never convert Figma status-bar
     or home-indicator canvas coordinates into padding.
   - Prefer native safe-area layout. Use `proxy.safeAreaInsets` only in a
     full-screen coordinate space. Assign each edge one inset owner—container,
     `safeAreaInset`, or explicit calculation—so it is never added twice.
   - Reuse an exact app asset. If a required visible asset is missing, acquire
     the exact Figma asset rather than substitute or redraw it. Raster imports
     use valid `@2x` and `@3x` only; omit `@1x` and never upscale.
5. Run the source fidelity gate:
   - all visible regions, text, states, outer frames, and inner glyphs match
     evidence; spacing, type, color, radius, border, shadow, blur, and opacity
     are not simplified when evidence exists;
   - no asset is omitted, redrawn, exported unnecessarily, or replaced by a
     near match;
   - interactive Figma glass maps to
     `BaseButton(style: .liquidAdaptive, ...)`; static glass uses an equivalent
     surface with matching shape/effect and earlier-iOS fallback;
   - header and bottom content anchor to their dynamic safe areas exactly once;
     responsive and 844pt rules preserve the baseline design.
6. Do not run prompt-injection scanning, GitNexus, `WORKFLOW_AI.md`, another
   project skill, tests, simulator, runtime capture, or pixel diff. Run
   `git diff --check`, then build the workspace once for `generic/platform=iOS`.
   Rebuild only after fixing a compiler error.
7. Report files, reused/acquired assets/components, compile status, and unresolved
   evidence. Build success proves compilation, not visual equality;
   claim runtime pixel validation only when explicitly authorized and executed.

If the edit crosses a quick boundary, switch to `flow`; never weaken MVI,
Factory, model placement, or Base ownership.

## Draft, flow, assets, and compare

- `draft`: follow quick rules, skip the build, report unverified compilation.
- `flow`: inspect the parent node's child screens, read
  `references/feature-flow.md`, then use only the skill owning the crossed
  boundary. Establish `frame → State → Intent → Route → Factory → justified
  Domain` before writing Views.
- `assets`: prefer an exact existing asset; otherwise acquire only the exact
  selected-node asset. Preserve catalog naming and raster scale rules.
- `compare`: read `references/visual-validation.md`. Simulator build, boot,
  capture, and pixel comparison require an explicit Simulator request; the
  word `compare` alone does not grant it.

Use the Figma family when bundled and registered; otherwise use the app's
primary bundled font. Preserve Figma size and map weight to the exact or closest
bundled face. Add no missing font unless requested. Treat generated reference
code as structural evidence only.

Short invocation: `$baseswiftui-figma-ui quick|draft|analyze|assets|compare|flow <node-url>`
