---
name: baseswiftui-architecture
description: Use when adding or refactoring non-view BaseSwiftUI architecture, broad feature structure, routes, MVI containers, repositories, services, use cases, factories, shared app infrastructure, navigation behavior, or feature folder structure under BaseSwiftUI/Base, BaseSwiftUI/MT-Screens, BaseSwiftUI/MT-CleanArchitecture, and BaseSwiftUI/MT-Factory. Do not use for ordinary normal SwiftUI view creation; baseswiftui-swiftui-ui already includes normal view architecture guidance. Do not use for IAP/paywall view work; use baseswiftui-iap-flow.
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
