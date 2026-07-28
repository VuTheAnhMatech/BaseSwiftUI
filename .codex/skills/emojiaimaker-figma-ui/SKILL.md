---
name: emojiaimaker-figma-ui
description: Use when analyzing, implementing, comparing, or updating EmojiAIMaker iOS UI from a Figma design URL or node, including one or multiple screens, normal SwiftUI screens, IAP/paywall screens, widgets, Figma assets, variables, Code Connect, and visual fidelity checks. Supports short analyze, implement, compare, and assets requests and routes automatically to the correct EmojiAIMaker project skills.
---

# EmojiAIMaker Figma UI

Turn a short Figma request into a complete, project-aware design-to-SwiftUI workflow. Treat Figma output as design evidence and adapt it to EmojiAIMaker rather than copying generated reference code.

## Interpret The Request

- `analyze`: inspect Figma and the project, report structure, reuse candidates, assets, and expected files; do not edit.
- `implement`: perform the full workflow, edit the project, validate, and compare. Use this mode when no mode is specified.
- `compare`: inspect the existing implementation against Figma, report concrete differences, and fix them only if the user also asks to edit or sync.
- `assets`: inspect and import only assets needed by the selected node while preserving asset-catalog naming and scope.
- For a parent node containing multiple screens, inventory all child screens and shared components first. Implement in coherent groups; do not flatten the entire flow into one view.

Require a node-specific Figma URL. If `node-id` is missing, ask for **Copy link to selection** rather than guessing a node.

## Load Required Guidance

Before calling Figma design-to-code tools, read these Figma MCP resources completely:

1. `skill://figma/figma-design-to-code/SKILL.md`
2. `skill://figma/figma-swiftui/SKILL.md`
3. `skill://figma/figma-swiftui/references/design-to-code.md`

Follow their gate protocol and tool requirements. When calling `get_design_context`, pass:

- `clientLanguages: "swift"`
- `clientFrameworks: "swiftui"`
- `skillNames: "resource:figma-design-to-code,resource:figma-swiftui"`

Then route the app work:

- Normal screen: read `.codex/skills/emojiaimaker-swiftui-ui/SKILL.md`.
- IAP, paywall, pricing, trial, purchase, restore, subscription, or sale UI: read `.codex/skills/emojiaimaker-iap-flow/SKILL.md` instead.
- WidgetKit, Live Activity, AppIntent, control, or extension-rendered UI: read `.codex/skills/emojiaimaker-widget-extension/SKILL.md`.
- Models, screen items, enums, default lists, mock data, or datasource inputs: also read `.codex/skills/emojiaimaker-model-organization/SKILL.md`.
- Broad non-view architecture: also read `.codex/skills/emojiaimaker-architecture/SKILL.md`.

Do not read every project skill by default. Read the smallest applicable set after classifying the selected Figma node.

## Acquire Design Evidence

1. Extract `fileKey` and convert the URL `node-id` from `337-54348` to `337:54348`.
2. Call `get_design_context` first. Do not substitute metadata or screenshot for it.
3. If the target is a page/canvas or returns sparse context, use metadata to locate visible child frames, then request design context for only the required frames, preferably in parallel.
4. Keep the returned screenshot as the visual source of truth. Use structure, exact text, tokens, annotations, Code Connect, and asset URLs from design context as implementation evidence.
5. Use `get_variable_defs`, metadata, screenshots, or asset tools only when they add information needed for implementation or validation.
6. Never claim a value came from Figma when it was inferred. Label uncertainty explicitly.

## Inspect Reuse Before Editing

Search the closest feature and these project-owned areas before creating code:

- `EmojiAIMaker/Base`
- `EmojiAIMaker/Widgets`
- `EmojiAIMaker/Exts`
- `EmojiAIMaker/Resources/Assets.xcassets`
- `EmojiAIMaker/Resources/Colors.xcassets`
- the nearest folder under `EmojiAIMaker/MT-Screens`
- related entities under `EmojiAIMaker/MT-CleanArchitecture/Domain/Entities`
- routes and Factory registrations when navigation or dependencies are involved

Build a small reuse map from each major Figma region to an existing project component, token, asset, system control, or justified new implementation. Prefer `BaseText`, `BaseButton`, `BaseNavBar`, `BaseDataSource` views, existing widgets, existing assets, Plus Jakarta Sans helpers, and global color tokens when they match.

## Implement Idiomatic EmojiAIMaker SwiftUI

- Preserve the selected design's visual intent while following project architecture and target boundaries.
- Treat React/Tailwind returned by Figma as structural reference only.
- Map Auto Layout to responsive SwiftUI flow; avoid copying absolute coordinates or frame-wide hard-coded dimensions.
- Use project Base collection views and `BaseDataSource`; do not introduce direct feature-view `ForEach`, `LazyVGrid`, `GridItem`, manual cell widths, or ad hoc collection loops.
- Put new entities and default/static data under the correct feature folder in `Domain/Entities`.
- Prefer an existing asset with a matching glyph. Otherwise download the exact Figma asset into the appropriate `.xcassets` namespace; do not silently redraw or substitute it.
- Map Figma variables to existing project tokens first. Add a shared token only when it is truly app-wide; use a one-off color at the callsite when project guidance requires it.
- Use existing navigation, MVI/container, Factory, purchase, and widget-extension patterns instead of introducing parallel abstractions.
- Keep changes limited to the requested node or flow.
- Use `Created by Vu The Anh` in new or updated file headers.

## Validate

1. Compare the implementation with the Figma screenshot for hierarchy, content, spacing, typography, color, radius, assets, safe areas, and scroll behavior.
2. Check compact-width behavior, long text, Dynamic Type implications, and interactive content near overlays or sticky controls.
3. Verify asset source and both outer-box and inner-glyph geometry as required by the Figma design-to-code gate.
4. Build through `EmojiAIMaker.xcworkspace` using the validation command from `emojiaimaker-ios-guidelines` when code changed.
5. Report completed files, reused components/assets/tokens, validation result, and any remaining design ambiguity.

## Short Invocation Examples

```text
$emojiaimaker-figma-ui analyze <figma-node-url>
$emojiaimaker-figma-ui implement <figma-node-url>
$emojiaimaker-figma-ui compare <figma-node-url>
$emojiaimaker-figma-ui assets <figma-node-url>
```
