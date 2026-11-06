---
name: baseswiftui-architecture
description: Build or refactor BaseSwiftUI non-view architecture, routes, MVI, services, repositories, use cases, factories, and end-to-end flows without Figma. Use figma-ui for Figma-led flows and dedicated UI skills for views.
---

# BaseSwiftUI Architecture

## Overview

Use this skill to keep new features and refactors aligned with BaseSwiftUI's
existing MVI, router, factory, and service boundaries.

Use `baseswiftui-swiftui-ui` instead for ordinary normal view creation. Use
`baseswiftui-iap-flow` instead for IAP/paywall view creation or editing.

## Project Map

- Router and presentation: existing router types under `BaseSwiftUI/Base`.
- MVI containers: colocated under `BaseSwiftUI/MT-Screens`.
- Factory pattern sample: `BaseSwiftUI/MT-Factory`.
- Feature screens: `BaseSwiftUI/MT-Screens`.
- Shared views: `BaseSwiftUI/Base`.
- Reusable helpers and type extensions: `BaseSwiftUI/Exts`.
- Network and app helpers: `BaseSwiftUI/Helper`.
- Domain entities and mock data: `BaseSwiftUI/MT-CleanArchitecture/Domain/Entities`.
  Read `.codex/skills/baseswiftui-model-organization/SKILL.md` before moving,
  creating, or reviewing models, default data, mock data, tab/section/item
  enums, or datasource-input types.
- MVI module contract: `BaseSwiftUI/Base/MVI/Module_README.md`.
- Network contract: `BaseSwiftUI/Base/Network/Network_README.md`.
- Repeated UI/data-source contract:
  `BaseSwiftUI/Base/DataSource/BaseListView_README.md`.

## Before Editing

- Inspect a nearby feature with the same shape before creating new files.
- Search for existing route, container, repository, service, and use case patterns.
- Decide whether the task is UI-only, domain logic, routing, persistence, networking, or cross-cutting infrastructure.

## Rules

- For generated or updated file header comments, always use
  `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another
  project/person name.
- Follow existing MVI/container patterns for new screens.
- Keep networking and persistence out of SwiftUI views.
- Put reusable business logic in use cases, services, repositories, or extensions based on the closest existing pattern.
- Prefer router abstractions over direct presentation hacks.
- Keep page navigation on the originating router stack. `ObservedStack.sheet`
  wraps presented content in a nested `AppRouter.Stack`, so the injected sheet
  router does not own the parent's `sheetRoute`.
- Presented sheet Views self-dismiss with `@Environment(\.dismiss)`. For async
  completion, publish a dismissal request from the Container and observe it in
  the View. Reserve `router.dismissSheet()` for the presenting parent router.
- Keep feature-specific code near the feature folder.
- Keep all models/entities/default/static/mock data under
  `MT-CleanArchitecture/Domain/Entities` feature/shared subfolders; do not
  declare them in Views, Containers, Exts, services, repositories, or factories.
- Keep reusable type extensions in `BaseSwiftUI/Exts`.
- Avoid broad refactors unless they directly reduce duplication needed by the requested change.

## Validation

- Confirm new code belongs to the selected layer.
- Check whether names and file placement match neighboring code.
- Verify no screen gained service or persistence logic that should live in a lower layer.
- Exercise `push -> sheet -> dismiss -> Back` after navigation changes and
  confirm presentation ownership remains synchronized.
