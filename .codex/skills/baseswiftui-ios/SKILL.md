---
name: baseswiftui-ios
description: Use when editing the BaseSwiftUI iOS app or when the user wants one routing skill for BaseSwiftUI work. For normal non-IAP SwiftUI view creation or editing, route to baseswiftui-swiftui-ui. For IAP, paywall, subscription, pricing, purchase, restore, trial, or sale views, route to baseswiftui-iap-flow. For WidgetKit or extension work, route to baseswiftui-widget-extension. For non-view architecture or broad refactors, route to baseswiftui-architecture.
---

# BaseSwiftUI iOS

Use this as the general routing skill for BaseSwiftUI iOS work. Prefer the more
specific project skills when the request clearly matches one of them:

- Use `baseswiftui-swiftui-ui` as the complete skill for normal non-IAP SwiftUI
  view creation, screen editing, shared view work, layout, visual polish, route
  wiring for that view, and view-local MVI/container placement.
- Use `baseswiftui-iap-flow` as the complete skill for IAP views, paywalls,
  pricing, sale labels, purchase, restore, product selection, Remote Config, and
  purchase SDK work.
- Use `baseswiftui-widget-extension` for WidgetKit, AppIntent, controls, Live Activity, extension targets, and shared widget UI work.
- Use `baseswiftui-architecture` for non-view architecture, broad feature
  structure, services, repositories, use cases, factories, shared
  infrastructure, and refactors.
- Use `baseswiftui-model-organization` whenever the task touches models,
  entities, tab/section/item enums, default/static lists, mock/sample data, or
  `BaseDataSource` inputs anywhere in the app.

## Session Bootstrap

When the user invokes `$baseswiftui-ios`, choose the one most specific project
skill first:

- For a normal view, read `.codex/skills/baseswiftui-swiftui-ui/SKILL.md`.
- For an IAP/paywall view, read `.codex/skills/baseswiftui-iap-flow/SKILL.md`.
- For widget extension work, read
  `.codex/skills/baseswiftui-widget-extension/SKILL.md`.
- For non-view architecture or broad refactors, read
  `.codex/skills/baseswiftui-architecture/SKILL.md`.
- For model, entity, default data, mock data, or datasource-input placement,
  read `.codex/skills/baseswiftui-model-organization/SKILL.md`.

Do not read every project skill by default. The normal view and IAP skills are
merged workflows and already include their required view architecture guidance.

If the task is architecture-heavy, also read the relevant workflow docs:

- `BaseSwiftUI/MT-CleanArchitecture/README.md`
- Nearby feature folders under `BaseSwiftUI/MT-Screens`
- Existing Factory registrations under `BaseSwiftUI/MT-Factory`
- Existing reusable UI under `BaseSwiftUI/Base` and `BaseSwiftUI/Widgets`

Do not read `weekly-report` for normal app coding tasks; use it only when the
user asks for a weekly report.

## Code Placement

- For generated or updated file header comments, always use
  `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another
  project/person name.
- Keep screen files focused on UI and screen-local state.
- Put reusable Swift extensions in dedicated files under `BaseSwiftUI/Exts`.
- Do not append reusable `extension` blocks to screen files such as `IAP01View.swift`, `IAP02View.swift`, or `IAP03View.swift`.
- Prefer naming extension files by type and purpose, for example `IAPProduct+SaleDisplay.swift`.

## IAP Screens

- Reuse existing product helpers for pricing and period text when the BaseSwiftUI IAP module exists.
- Search existing helpers before adding new ones, especially related files under `BaseSwiftUI/Exts`.
- Avoid creating multiple helpers that return the same value or equivalent wording; prefer reusing or lightly adapting the existing helper.
- When adding pricing display behavior that may be reused by multiple IAP screens, implement it in `BaseSwiftUI/Exts`.
- Keep IAP screen-specific selection logic inside the screen view.

## Project Areas

- App target: `BaseSwiftUI`.
- Shared SwiftUI components: `BaseSwiftUI/Base`.
- Shared widget UI: `BaseSwiftUI/Widgets`.
- Navigation and presentation: existing router types under `BaseSwiftUI/Base`.
- MVI containers: colocated under `BaseSwiftUI/MT-Screens`.
- Feature screens: `BaseSwiftUI/MT-Screens`.
- Factory registrations: `BaseSwiftUI/MT-Factory`.
- Domain entities and mock data: `BaseSwiftUI/MT-CleanArchitecture/Domain/Entities`.
  Use feature/shared subfolders as required by `baseswiftui-model-organization`.

## Before Editing

- Check for existing helpers, base views, routers, and feature patterns before adding new abstractions.
- Keep changes scoped to the requested feature or screen.
- Do not move code across app and extension targets unless the target boundary is part of the task.
