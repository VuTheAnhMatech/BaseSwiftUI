---
name: baseswiftui-figma-ui
description: "Implement BaseSwiftUI UI from an exact Figma node: quick local View, screen with existing-pattern wiring, or multi-screen/data flow. Also analyze, acquire assets, or compare designs. Paywalls belong to iap-flow."
---

# BaseSwiftUI Figma UI

Use exact Figma evidence. Paywalls belong to `baseswiftui-iap-flow`.

## Routes

- `quick` (default): one exact node, local View, fidelity gate, one generic build.
- `screen`: one screen plus existing-pattern Container/items/route/Factory.
- `draft`: edit without building only when the user explicitly requests it.
- `analyze`: report only; do not edit.
- `assets`: asset-only inspection or acquisition for the selected node.
- `compare`: use `references/visual-validation.md`.
- `flow`: multiple screens, changed shared contracts, or new domain/data/network
  behavior; read `references/feature-flow.md`. File count alone is not a trigger.

Require a node-specific link. Ask for **Copy link to selection** only when its
`node-id` is absent. Decide the route before inspecting repository code.

## Quick route

1. Call `get_design_context` once for the exact node with language `swift` and
   framework `swiftui`; reuse it during this task unless the design changes.
   Use its screenshot as visual truth; request one exact-node screenshot only
   if absent or unreadable.
2. Open only the target View and exact reused component/asset definitions via
   bounded `rg`. If the user says assets exist, reuse them and never export.
3. Classify `frame · spacing · type · effects · assets · safe area` as Figma
   evidence, project mapping, or unresolved; output no plan. Resolve only
   material unknowns with the specific evidence call needed. Load no generic
   Figma guideline resources.
4. Edit the View once while keeping these contracts:
   - Render state and forward intents; keep business logic outside Views. Reuse Base components/tokens. Put cross-screen typed UI, generic UI adapters/layouts, and app-wide overlays in `Widgets` with a README contract; never bind them to one Container or move feature-local UI there.
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
   - Reuse an exact app asset. Group new sets in namespaced screen folders and
     reference paths such as `Home/ic_setting`; cross-screen assets belong in
     `Shared`. If missing, acquire the exact Figma asset rather than redraw it.
     Raster imports use `@2x`/`@3x` only; omit `@1x` and never upscale.
   - Reuse catalog RGBA via typed resources (`Color(.OP.OP_01)`), never strings;
     never RGB/hex. If missing, use the Figma variable/style path
     (for example `Semantic/Croal`), else `Color<RRGGBB><AA-percent>`
     (`ColorFFFFFF10`); omit alpha at 100%.
5. Run the source fidelity gate:
   - all visible regions, text, states, outer frames, and inner glyphs match
     evidence; spacing, type, color, radius, border, shadow, blur, and opacity
     are not simplified when evidence exists;
   - every color uses a catalog-generated typed accessor; no string lookup,
     View-local color property, or inline RGB/hex duplicates it;
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

## Other routes

- `draft`: follow quick rules, skip the build, report unverified compilation.
- `screen`: keep quick evidence/fidelity rules; expand source reads using
  `.codex/skills/baseswiftui-swiftui-ui/references/navigation-ownership.md` without
  loading another skill. Root shared-symbol impact applies; build once.
- `flow`: read `references/feature-flow.md`; inspect child screens only for
  multi-screen work. Load only guidance for the contract/data boundary crossed.
- `analyze`: inspect evidence and report; no edits, build, or indexing.
- `assets`: prefer an exact existing asset; otherwise acquire only the exact
  selected-node asset. Preserve screen/shared namespaces and scale rules.
- `compare`: read `references/visual-validation.md`. Simulator build, boot,
  capture, and pixel comparison require an explicit Simulator request; the
  word `compare` alone does not grant it.

Use the Figma family when bundled and registered; otherwise use the app's
primary bundled font. Preserve Figma size and map weight to the exact or closest
bundled face. Add no missing font unless requested. Treat generated reference
code as structural evidence only.

Short invocation: `$baseswiftui-figma-ui quick|screen|draft|analyze|assets|compare|flow <node-url>`
