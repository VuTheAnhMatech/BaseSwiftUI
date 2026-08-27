---
name: baseswiftui-figma-ui
description: Analyze, implement, or compare BaseSwiftUI screens and complete flows from a Figma MCP node. Covers assets, MVI/routes, IAP, shared UI, and visual validation. Requires a node-specific Figma link.
---

# BaseSwiftUI Figma UI

Coordinate design evidence and the smallest BaseSwiftUI implementation skills.
Adapt Figma output to the project; never copy generated reference code blindly.

## Mode and scope

- `analyze`: report structure, reuse, assets, and expected files; do not edit.
- `implement` (default): implement, build, and compare.
- `compare`: report concrete differences; edit only when asked to fix/sync.
- `assets`: acquire only assets required by the selected node.

Require a node-specific URL. If `node-id` is absent, ask for **Copy link to
selection**. For a parent node, inventory child screens and shared regions
before choosing implementation groups. For a complete/multi-screen flow, read
`references/feature-flow.md` before code. For `implement` or `compare`, read
`references/visual-validation.md` before final comparison.

## Acquire design evidence

Before tool calls, read `skill://figma/figma-design-to-code/SKILL.md`,
`skill://figma/figma-swiftui/SKILL.md`, and
`skill://figma/figma-swiftui/references/design-to-code.md`. Call
`get_design_context` first with:

- `clientLanguages: "swift"`
- `clientFrameworks: "swiftui"`
- `skillNames: "resource:figma-design-to-code,resource:figma-swiftui"`

Extract `fileKey` and convert URL node IDs such as `337-54348` to
`337:54348`. If a page/canvas returns sparse context, use metadata to locate
visible frames, then request only the required frame contexts, in parallel when
possible. Keep the returned screenshot as visual evidence. Request variables,
metadata, Code Connect, or asset data only when it resolves an implementation
decision. Label inferred values; do not attribute them to Figma.

## Route after inspecting the node

- Normal app UI → `baseswiftui-swiftui-ui`
- Paywall/IAP → `baseswiftui-iap-flow`
- Models, defaults, mocks, or list inputs → also
  `baseswiftui-model-organization`
- Broad non-view functional flow → also `baseswiftui-architecture`

Do not load every project skill. This skill owns Figma evidence and flow
coordination; the selected implementation skill owns code rules.

## Adapt and implement

Before creating code, map each major Figma region to an existing project
component, widget, token, asset, system control, or justified new element.
Inspect only the nearest feature plus relevant `Base`, `Widgets`, `Exts`, asset
catalogs, entities, routes, and Factory registrations.

Map Auto Layout to responsive SwiftUI rather than absolute coordinates. Reuse
project components/tokens when they match. Use the exact Figma asset when no
matching project asset exists, preserving catalog naming and scope. Treat
React/Tailwind output as structural evidence only. Keep edits limited to the
selected node/flow and new/updated headers as `Created by Vu The Anh`.

Typography uses the font family already bundled and documented by the project,
even when Figma specifies another family. Map Figma size, weight, and line
height to the closest available project style and continue without asking;
add or download fonts only when the user explicitly requests it.

For raster assets exported through Figma MCP or extracted from a supplied
screenshot, create only correctly sized `@2x` and `@3x` renditions for the same
point size; omit `@1x`. Never label one bitmap as both scales or upscale an
insufficient source.

For a flow, establish `frame → State → Intent → Route → Factory → justified
Domain` ownership before writing Views. Do not flatten multiple screens into
one View.

## Validate

Follow `references/visual-validation.md` and the selected implementation
skill. Build through `BaseSwiftUI.xcworkspace` when Swift changed. Report
files, reused/new components/assets/tokens, comparison evidence, ambiguities,
and untested states. Never claim numeric fidelity without a measuring tool.

Short invocations:
`$baseswiftui-figma-ui analyze|implement|compare|assets <figma-node-url>`
