---
name: baseswiftui-architecture
description: Build or refactor BaseSwiftUI non-view architecture, routes, MVI, services, repositories, use cases, factories, and end-to-end flows without Figma. Use figma-ui for Figma-led flows and dedicated UI skills for views.
---

# BaseSwiftUI Architecture

Use ProjMaker as the primary structure/runtime reference and preserve every
existing BaseSwiftUI layer. Read `docs/architecture.md` for boundaries.

## Inspect

- App entry: `BaseSwiftUI/Core/App`.
- State/Intent/Effect and lifecycle: `BaseSwiftUI/Core/Container/README.md`.
- Router and presentation ownership: `BaseSwiftUI/Core/Navigation/README.md`.
- Factory-backed composition: `BaseSwiftUI/Core/DI/README.md`.
- Features: `BaseSwiftUI/Presentation/Screens`; shared UI: `Presentation/Views`.
- Business entities/protocols/use cases: `BaseSwiftUI/Domain`.
- DTOs/repository implementations/services: `BaseSwiftUI/Data`.
- Network: `BaseSwiftUI/Core/Network/Network_README.md`.
- Repeated UI: `BaseSwiftUI/Presentation/DataSource/BaseListView_README.md`.
- Helpers/extensions: `BaseSwiftUI/Utils`.

Read only the relevant contracts and the nearest feature. Use
`.codex/skills/baseswiftui-model-organization/SKILL.md` when model ownership changes.
Use UI/IAP skills for screen design work.

## Implement

- New/updated headers use `Created by Vu The Anh`.
- Feature groups State, Intent, Effect; Container overrides async dispatch and
  dispatchSystem. Mutate through updateState; publish one-shot sendEffect events.
- View renders state, sends Intent, attaches lifecycle and observes Effect.
- Data flow remains View → Container → UseCase → Repository → Service; preserve
  Domain protocols, Data implementations, DTO mapping and existing infrastructure.
- AppDIFactory composes one Factory registry with ScreenDIFactory. Keep Service/
  Repository/UseCase registration files; avoid pass-through wrapper objects.
  Inject UseCase protocols into Containers. No Container.shared in UI.
- AppRouteFactory maps AppRoute. Views navigate with Environment router; Containers
  do not own routers. Each presentation owns its path; use current router dismiss.
- Domain entities, Data DTOs and Presentation items stay in their owning layers;
  defaults/mocks stay beside their models. Do not import UI into Domain.
- Preserve iOS 17, Swift 5, Combine/ObservableObject, Factory, CocoaPods, workspace,
  iPhone/iPad support, Network, CoreData, DataSource, shared views and widgets.
- Keep changes scoped to the requested feature or migration.

## Verify

Check layers, lifecycle/cancellation/effects, route/DI wiring and list ownership.
Run relevant host regressions and generic iOS workspace build. For navigation,
verify state for push → sheet → dismiss → Back and root replacement. Do not claim
native UI transitions were tested without device evidence; Simulator use requires
explicit user request.
