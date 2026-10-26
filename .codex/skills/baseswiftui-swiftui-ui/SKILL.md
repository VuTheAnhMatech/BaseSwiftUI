---
name: baseswiftui-swiftui-ui
description: Edit normal BaseSwiftUI UI or add one screen with existing-pattern Container, UI items, route and Factory wiring. Excludes exact Figma nodes, paywalls, and changes to shared architecture contracts or data flow.
---

# BaseSwiftUI SwiftUI UI

Use `local` for an existing View/component edit; `screen` for one screen with
existing-pattern Container/items/route/Factory. Exact Figma nodes belong to
`baseswiftui-figma-ui`, paywalls to `baseswiftui-iap-flow`. Changed shared
contracts or source-backed data flow belong to `baseswiftui-architecture`.

## Inspect only what is needed

1. Read the target and direct reused definitions. For `screen`, inspect one
   closest feature and `references/navigation-ownership.md`; do not survey all Base,
   Widgets, Exts, or screens. Reuse unchanged context within the task.
2. For repeated UI, inspect the closest component under
   `BaseSwiftUI/Base/DataSource`; use its documented contract.
3. Local UI items/defaults stay beside the feature in separate files. Follow
   the model ownership in `MT-CleanArchitecture/README.md` only when unclear;
   adding a UI item does not require the model-organization skill.
4. For routes, sheets, or dismissal, read
   `references/navigation-ownership.md`.
5. For animation, focus, programmatic scrolling, remote images, localization,
   Charts, or previews, read only the relevant section of
   `references/interaction-content-patterns.md`.

## Implement

- Mirror the nearest feature structure. New/updated header comments use
  `Created by Vu The Anh`.
- Views render state, keep truly local UI state, and forward user actions.
  Containers own screen state and `BaseDataSource`; networking, persistence,
  and business logic stay in the existing lower layer.
- Put cross-screen reusable UI, generic UI layouts/adapters, and app-wide
  overlays in `Widgets`. Configure visual widgets by focused types/models and
  action closures, document the contract and call site in `Widgets/README.md`,
  and keep Container state/intents and feature-specific UI outside.
- Keep business entities in Domain and UI-only items in `MT-Screens/<Feature>`;
  defaults stay beside their model. Preserve legacy placement unless moving
  models is requested. Keep Feature/State/Intent with the Container.
- Use existing router and Factory patterns for navigation and dependencies.
  Add broader layers only when behavior requires them.
- Prefer `BaseText`, `BaseButton`, `BaseNavBar`, matching widgets, existing
  assets, and global color tokens. Preserve the local visual language.
- Before adding a color, search `Resources/Colors.xcassets` by RGBA and reuse
  its generated typed resource, such as `Color(.OP.OP_01)`; never use string
  lookup or View-local RGB/hex. If missing, create its supplied semantic path;
  otherwise use `Color<RRGGBB><AA-percent>` (`ColorFFFFFF10`) and omit alpha at
  100%.
- Let `BaseButton` keep its default adaptive style: it applies Liquid Glass on
  iOS 26+ when enabled and uses a material fallback below iOS 26. Pass `.plain`
  only when the design explicitly requires a non-glass action.
- Use the design's font family when that family is already bundled and
  registered; otherwise use the app's primary bundled font. Preserve the
  requested size and map weight to the exact or closest bundled face. Add font
  files only when explicitly requested.
- Raster assets exported through Figma MCP or extracted from a supplied
  screenshot use correctly sized `@2x` and `@3x` renditions only; omit `@1x`.
  Never label one bitmap as both scales or upscale an insufficient source.
- Put image sets in namespaced screen folders and reference paths such as
  `Home/ic_setting`; only genuinely cross-screen assets belong in `Shared`.
  Do not leave feature assets flat at the catalog root.
- Use generated resources in Swift (`Image(.Home.icSetting)`), never string
  asset lookup or wrapper variables for a static image.
- Render repeated content with `BaseDataSource` plus `BaseGridView`,
  `BaseScrollView`, `BaseStackView`, `BaseLazyListView`, or `BaseListView`.
  Feature Views do not create direct collection loops or manual cell widths.
- For fixed screen content, Figma height above 844pt uses a screen-level
  `ScrollView`; height at or below 844pt uses no screen-level `ScrollView` and
  must adapt responsively from iPhone SE through iPhone 17 Pro Max. Base
  list/grid components remain intrinsically scrollable regardless of height.
- Keep layouts responsive to compact width. `Image("ic_close")` remains
  exactly 40×40.
- Put reusable extensions in `BaseSwiftUI/Exts`; do not create screen-local
  type extensions or feature color namespaces.
- Keep simple one-off layout values at the callsite. Extract only meaningful
  reuse or a cross-file contract. Avoid unrelated refactors.

## Validate

Check render-only View ownership, model/list placement, reuse, route/Factory
consistency, compact width, clipping, Dynamic Type, VoiceOver labels/order,
touch targets, Reduce Motion where relevant, and the states changed by the
task. Inspect affected navigation and dismissal edges; runtime checks require
an available authorized device. Build once through `BaseSwiftUI.xcworkspace`
for `generic/platform=iOS` when Swift changed; repeat after fixes/new changes. Never
select, build, boot, or open Simulator unless the user explicitly requests it.

Use `baseswiftui-swiftui-review` for a dedicated audit or Instruments trace, and
`baseswiftui-security-review` for a dedicated trust-boundary review.
