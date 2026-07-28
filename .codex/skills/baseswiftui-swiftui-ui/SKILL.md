---
name: baseswiftui-swiftui-ui
description: Use whenever the user asks to create, add, build, implement, edit, or polish a normal non-IAP SwiftUI view or screen in BaseSwiftUI, including screens under BaseSwiftUI/MT-Screens, reusable views under BaseSwiftUI/Base, widget-like shared UI under BaseSwiftUI/Widgets, layout fixes, compact-width behavior, route wiring for that view, MVI/container placement for that view, and UI refactors that should follow the app's existing design patterns. Do not use for IAP, paywall, pricing, purchase, restore, subscription, trial, or sale-badge views; use baseswiftui-iap-flow for those.
---

# BaseSwiftUI SwiftUI UI

## Overview

Use this as the complete workflow for normal non-IAP BaseSwiftUI SwiftUI view
work. It intentionally includes the UI, route, MVI, factory, and file placement
rules needed for ordinary view creation so the agent does not need to read a
separate architecture skill first.

If the view is an IAP, paywall, pricing, subscription, trial, purchase,
restore, or sale screen, stop using this skill and use `baseswiftui-iap-flow`
instead.

## Project Map

- Feature screens: `BaseSwiftUI/MT-Screens`.
- Shared SwiftUI components: `BaseSwiftUI/Base`.
- Shared widget-like UI: `BaseSwiftUI/Widgets`.
- Router and presentation: existing router types under `BaseSwiftUI/Base`.
- MVI containers: colocated under `BaseSwiftUI/MT-Screens`.
- Factory pattern sample: `BaseSwiftUI/MT-Factory`.
- Reusable helpers and type extensions: `BaseSwiftUI/Exts`.
- Network and app helpers: `BaseSwiftUI/Helper`.

## Before Editing

- Decide whether the requested view is a normal view or an IAP/paywall view.
  Use this skill only for normal views.
- Inspect a nearby screen or feature with the same shape before creating new
  files.
- Search existing reusable UI first:
  - `BaseSwiftUI/Base`
  - `BaseSwiftUI/Widgets`
  - `BaseSwiftUI/Exts`
  - nearby files in the same `MT-Screens` feature folder
- Search existing Base data-source components before rendering any collection:
  - `BaseSwiftUI/Base/DataSource/Core/BaseDataSource.swift`
  - `BaseSwiftUI/Base/DataSource/Core/BaseGridView.swift`
  - `BaseSwiftUI/Base/DataSource/Core/BaseScrollView.swift`
  - `BaseSwiftUI/Base/DataSource/Core/BaseStackView.swift`
  - `BaseSwiftUI/Base/DataSource/Core/BaseLazyListView.swift`
  - `BaseSwiftUI/Base/DataSource/Core/BaseListView.swift`
- If the view introduces or edits models, section/tab/item enums, default
  lists, mock data, or datasource inputs, read
  `.codex/skills/baseswiftui-model-organization/SKILL.md` before editing.
- Search for existing route, container, factory, repository, service, and use
  case patterns before adding new abstractions.
- Check whether the requested UI belongs to the app target, widget target, or
  both.
- Decide whether the task is UI-only, local screen state, routing, domain logic,
  persistence, networking, or cross-cutting infrastructure.
- Preserve the local screen structure unless the task asks for a refactor.

## Normal View Creation Workflow

1. Find the closest existing feature folder and mirror its file structure.
2. Add the SwiftUI view under the correct `BaseSwiftUI/MT-Screens` feature folder
   unless the existing project pattern places that view elsewhere.
   If adding or updating a file header comment, always use
   `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another
   project/person name.
3. Put new screen/domain models, style items, mock/default data, and enums under
   `BaseSwiftUI/MT-CleanArchitecture/Domain/Entities`, not inside the View,
   Container, or Exts. Follow `baseswiftui-model-organization`: use a feature
   subfolder when the model is not shared app-wide, and use `Shared/` only for
   truly shared app-wide entities.
4. Initialize list data in the Container or data provider and expose it through
   `BaseDataSource`; do not build static lists inside SwiftUI view files.
5. Keep UI rendering, focus/local control state, and user interaction forwarding
   in the view.
6. If the view needs presentation or navigation, wire it through the existing
   router and factory patterns instead of direct presentation hacks.
7. If the view needs business logic, networking, persistence, or reusable data
   shaping, place that logic in the nearest existing use case, service,
   repository, helper, or extension pattern.
8. Reuse existing `Base/Views`, `Base/DataSource`, `Widgets`, and `Exts` helpers before adding new
   UI primitives.
9. Keep changes scoped to the requested view or feature.

## UI Rules

- Keep screen files focused on layout, local state, and user interactions.
- Move repeated formatting or conversion logic into `BaseSwiftUI/Exts`.
- Reuse `BaseText`, `BaseButton`, `BaseNavBar`, and other `Base/Views` components when they fit the existing screen style.
- Use `BaseDataSource` plus `BaseGridView`, `BaseScrollView`, `BaseStackView`,
  `BaseLazyListView`, or `BaseListView` for repeated content. Do not write
  direct `ForEach`, `LazyVGrid`, `GridItem`, manual cell-width calculation, or
  ad hoc horizontal `ScrollView` loops in feature views.
- Reuse `BaseSwiftUI/Widgets` views for widget-like UI instead of duplicating layout code.
- Whenever rendering `Image("ic_close")`, always frame it at exactly
  `width: 40, height: 40`.
- Avoid introducing a new visual language unless the user explicitly asks for a redesign.
- Prefer responsive SwiftUI layout over hard-coded screen dimensions.
- Do not introduce private `Metrics`, `Constants`, or similar enums/structs just
  to hold small one-off layout values used only in the same view. Write simple
  padding, spacing, count, ratio, and frame literals directly at the callsite.
  Extract a named constant only when the value is a shared contract across files,
  is reused in several places, or substantially improves clarity.
- Keep text resilient to long localized strings and compact-width devices.
- Do not append reusable `extension` blocks to screen files. Put reusable Swift
  extensions in dedicated files under `BaseSwiftUI/Exts`.
- Do not create feature-specific `Color` namespaces such as
  `extension Color { enum Explore { ... } }` just to alias colors for one
  screen. Use existing global color tokens directly, or write one-off
  `Color(...)`, `.white`, `.black`, or opacity expressions directly at the
  callsite.

## Architecture Rules

- Follow existing MVI/container patterns for new screens when the surrounding
  feature uses them.
- Keep networking and persistence out of SwiftUI views.
- Put reusable business logic in use cases, services, repositories, helpers, or
  extensions based on the closest existing pattern.
- Prefer router abstractions over direct presentation or navigation hacks.
- Keep feature-specific code near the feature folder.
- Avoid broad refactors unless they directly reduce duplication needed by the
  requested view.

## Validation

- Check compact-width layout mentally from the SwiftUI hierarchy.
- Verify no text is likely to overlap or be clipped by fixed frames.
- Confirm helper code did not get appended to a screen file when it belongs in `BaseSwiftUI/Exts`.
- Confirm list data is not initialized in a SwiftUI view.
- Confirm screen/domain models are not declared in Views or Containers.
- Confirm repeated UI is driven by `BaseDataSource` and Base data-source views.
- Confirm one-off layout literals were not hidden behind private `Metrics` or
  `Constants` enums/structs.
- Confirm new code belongs to the selected layer.
- Check whether names and file placement match neighboring code.
- Verify no screen gained service, networking, or persistence logic that should
  live in a lower layer.
