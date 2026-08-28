---
name: baseswiftui-figma-ui
description: Implement high-fidelity BaseSwiftUI UI from an exact Figma MCP node with a fast one-View default, bounded evidence escalation, architecture preservation, and optional flow or visual comparison modes.
---

# BaseSwiftUI Figma UI

Use Figma as design evidence and preserve the existing BaseSwiftUI structure.

## Routes

- `quick` (default): one exact node, one feature-local View, a source-level
  fidelity gate, then one `generic/platform=iOS` build.
- `draft`: edit without building only when the user explicitly requests it.
- `analyze`: report only; do not edit.
- `assets`: acquire only explicitly requested missing assets.
- `compare`: use `references/visual-validation.md`.
- `flow`: multiple screens or any route, Factory, shared/Base, model/list, IAP,
  domain, data, or network change; read `references/feature-flow.md`.

Require a node-specific link. Ask for **Copy link to selection** only when its
`node-id` is absent. Decide the route before inspecting repository code.

## Quick route

1. Call `get_design_context` once for the exact node with language `swift` and
   framework `swiftui`. Keep its screenshot as the visual source of truth.
   Do not preload another Figma/project skill.
2. Open only the target View and exact reused component/asset definitions found
   with bounded `rg`; do not scan the whole feature, repository, or asset
   catalog. If the user says assets exist, reuse them and never export.
3. Mentally map each major region to an existing component, token, asset,
   system control, or justified local implementation; output no plan document.
4. Apply the complete View edit once. Keep these local invariants:
   - View renders state and forwards intents; no networking, persistence, or
     business logic.
   - Reuse existing `BaseText`, `BaseButton`, `BaseNavBar`, widgets, assets,
     colors, and bundled fonts. Do not modify `Base` or shared architecture.
   - For fixed screen content, use the Figma frame height as the switch: above
     844pt uses a screen-level `ScrollView`; 844pt or below uses no screen-level
     `ScrollView` and must adapt responsively from iPhone SE through iPhone 17
     Pro Max. Intrinsically scrolling lists/grids keep their Base component
     contract regardless of frame height.
   - Preserve Figma baseline geometry and effects; never scale the whole screen.
   - Only backgrounds may `ignoresSafeArea()`; foreground anchors to iOS's dynamic top/bottom safe areas. Never hard-code 44pt/34pt insets or branch by device.
   - Separate system insets from design spacing. If Figma shows a status bar or home indicator, do not reuse its canvas coordinates as padding.
   - Prefer native safe-area layout; use `proxy.safeAreaInsets` only in full-screen coordinates and never add an inset twice.
   - Reuse a matching app asset. If none exists and the visible asset is needed
     for fidelity, acquire the exact Figma asset instead of drawing a substitute
     or using a similar SF Symbol. Raster imports use valid `@2x` and `@3x` only;
     omit `@1x` and never upscale an insufficient source.
5. Before editing with incomplete evidence, escalate only the missing part:
   screenshot when no usable node screenshot exists; variables for unresolved
   tokens; metadata for sparse/page context; asset data for a required missing
   asset. Do not request all evidence speculatively or load the three generic
   Figma guideline resources for a routine local View.
6. Run this source-level fidelity gate before reporting completion:
   - every visible region, text, and state is represented;
   - outer frames and inner glyph geometry follow Figma evidence;
   - spacing, typography, color, radius, border, shadow, blur, and opacity were
     not simplified or guessed when evidence exists;
   - no asset was silently omitted, redrawn, or replaced with a near match;
   - every Figma glass layer maps to `BaseButton(style: .liquidAdaptive, ...)` when interactive, or an equivalent glass implementation with fallback;
   - headers anchor to the dynamic top safe area and bottom content anchors to the dynamic bottom safe area without double insets;
   - baseline geometry is not implemented with whole-screen `scaleEffect` or
     absolute coordinate duplication;
   - responsive and 844pt scroll rules do not alter the baseline design.
7. Do not run prompt-injection scanning, GitNexus, `WORKFLOW_AI.md`, another
   project skill, tests, simulator, runtime screenshot capture, or pixel diff.
   Run `git diff --check`, then build the workspace once for
   `generic/platform=iOS`. Fix compiler errors and rebuild only after a fix.
8. Report changed files, reused/acquired assets and components, compile status,
   and any unresolved Figma ambiguity. Do not claim runtime pixel validation
   unless an explicitly authorized comparison actually ran.

If the edit crosses a quick boundary, switch to `flow`; never weaken MVI,
Factory, model placement, or Base ownership.

## Draft, flow, assets, and compare

- `draft`: follow quick rules, skip the build, and report unverified compilation.
- `flow`: inspect the parent node's child screens, read
  `references/feature-flow.md`, then use only the skill owning the crossed
  boundary. Establish `frame → State → Intent → Route → Factory → justified
  Domain` before writing Views.
- `assets`: acquire only assets needed by the selected node. Prefer an exact
  existing asset; otherwise export the exact Figma asset. Raster assets use
  correctly sized `@2x` and `@3x` only; omit `@1x`, do not upscale, and
  preserve catalog naming.
- `compare`: read `references/visual-validation.md`. Simulator build, boot,
  capture, and pixel comparison require an explicit Simulator request; the
  word `compare` alone does not grant it.

Use the Figma family when bundled and registered; otherwise use the app's
primary bundled font. Preserve Figma size and map weight to the exact or closest
bundled face. Add no missing font unless requested. Treat generated reference
code as structural evidence only.

Short invocation: `$baseswiftui-figma-ui quick|draft|analyze|assets|compare|flow <node-url>`
