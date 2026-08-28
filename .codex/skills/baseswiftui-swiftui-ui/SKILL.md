---
name: baseswiftui-swiftui-ui
description: Build, edit, or polish normal BaseSwiftUI views, screens, shared UI, layouts, view routes, and view-local MVI wiring. Excludes IAP and paywalls.
---

# BaseSwiftUI SwiftUI UI

Complete workflow for normal in-app UI. Route paywalls/IAP to
`baseswiftui-iap-flow`.

## Inspect only what is needed

1. Inspect the closest screen with the same shape and reuse from
   `BaseSwiftUI/Base`, `Widgets`, `Exts`, resources, and the nearby feature.
2. For repeated UI, inspect the closest component under
   `BaseSwiftUI/Base/DataSource`; use its documented contract.
3. If models, enums, defaults, mocks, or list inputs change, also use
   `baseswiftui-model-organization`.
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
- Put screen/domain entities and reusable default/mock data under
  `MT-CleanArchitecture/Domain/Entities`, using a feature folder unless truly
  shared app-wide.
- Use existing router and Factory patterns for navigation and dependencies.
  Add broader layers only when behavior requires them.
- Prefer `BaseText`, `BaseButton`, `BaseNavBar`, matching widgets, existing
  assets, and global color tokens. Preserve the local visual language.
- Let `BaseButton` keep its default adaptive style: it applies Liquid Glass on
  iOS 26+ when enabled and falls back to plain below iOS 26. Pass `.plain` only
  when the design explicitly requires a non-glass action.
- Use the bundled/documented project font even when a design or screenshot
  names another family; map to the closest size/weight without asking. Add font
  files only when explicitly requested.
- Raster assets exported through Figma MCP or extracted from a supplied
  screenshot use correctly sized `@2x` and `@3x` renditions only; omit `@1x`.
  Never label one bitmap as both scales or upscale an insufficient source.
- Render repeated content with `BaseDataSource` plus `BaseGridView`,
  `BaseScrollView`, `BaseStackView`, `BaseLazyListView`, or `BaseListView`.
  Feature Views do not create direct collection loops or manual cell widths.
- Make every layout adaptive from iPhone SE through iPhone 17 Pro Max,
  independent of design height. Separately, height above 844pt does not itself
  require `ScrollView`; scroll only for inaccessible irreducible content,
  Dynamic Type, keyboard presentation, or long localization. Never use 844pt
  as an Auto Layout trigger.
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
task. Exercise affected navigation and dismissal edges. Build through
`BaseSwiftUI.xcworkspace` for `generic/platform=iOS` when Swift changed. Never
select, build, boot, or open Simulator unless the user explicitly requests it.

Use `baseswiftui-swiftui-review` for a dedicated audit,
`baseswiftui-performance-trace` for Instruments, and
`baseswiftui-security-review` for a dedicated trust-boundary review.
