---
name: baseswiftui-architecture
description: Design or refactor BaseSwiftUI contracts, data flow, persistence, navigation/DI; audit model ownership or provide explicitly requested project guidelines. Use for architecture and layer decisions; routine screen wiring belongs to UI/Figma. Simple code explanations need no skill.
---

# BaseSwiftUI Architecture

Keep new features and refactors aligned with BaseSwiftUI's MVI, router,
Factory, and Clean Architecture boundaries.

Use `baseswiftui-swiftui-ui` for local UI or existing-pattern screen wiring and
`baseswiftui-iap-flow` for IAP/paywall work.

## Modes and conditional context

- `change`: shared contracts, layers, navigation/DI mechanisms, or data flow.
  Read `AI-Workflow/WORKFLOW_AI.md` and only the relevant source guide.
  Use the workflow below; routine UI items/route entries stay with UI/Figma.
- `models`: dedicated ownership audit or migration. Read
  `references/model-organization.md` and the ownership section of
  `BaseSwiftUI/MT-CleanArchitecture/README.md`. Read the workflow only if a
  migration changes architecture/data flow. Keep this primary skill.
- `guidelines`: only when complete project guidelines are explicitly requested,
  read `references/ios-guidelines.md`; do not preload it for ordinary work.

Questions, design proposals, and audits remain read-only: no moves, build, or
indexing. Implementation steps below apply only to requested code changes.

## Project map

- Router and presentation foundation: `BaseSwiftUI/Base`.
- MVI module contract: `BaseSwiftUI/Base/MVI/Module_README.md`.
- Feature screens and containers: `BaseSwiftUI/MT-Screens`.
- Factory and route composition: `BaseSwiftUI/MT-Factory`.
- Clean Architecture source of truth: `BaseSwiftUI/MT-CleanArchitecture`.
- Shared views: `BaseSwiftUI/Base`.
- Reusable helpers and type extensions: `BaseSwiftUI/Exts`.
- Network contract: `BaseSwiftUI/Base/Network/Network_README.md`.
- Repeated UI/data-source contract:
  `BaseSwiftUI/Base/DataSource/BaseListView_README.md`.

## Workflow

1. Inspect a nearby feature with the same shape.
2. Classify the change as UI-only, domain logic, routing, persistence,
   networking, or mixed.
3. Add only justified layers. Do not create empty folders or pass-through
   types solely to resemble a diagram.
4. Keep dependency direction `Presentation -> Domain <- Data`; let DI create
   concrete implementations.
5. Wire new dependencies through the matching Factory registrations.
6. Preserve existing behavior while moving code; separate structural moves
   from behavior changes when practical.

## Canonical feature shape

Use this as the default shape, then omit folders with no real responsibility:

```text
<Feature>/
├── Domain/
│   ├── Entities/
│   ├── Repositories/
│   └── UseCases/
├── Data/
│   ├── DTOs/
│   ├── DataSources/{Local,Remote}/
│   ├── Mappers/
│   ├── Repositories/
│   └── Services/
├── Presentation/
│   ├── Views/
│   ├── Containers/
│   ├── Components/
│   ├── Representables/
│   └── State/
├── Navigation/{Routes,Coordinators}/
└── DI/<Feature>Factory.swift
```

BaseSwiftUI may keep app entities in `MT-CleanArchitecture/Domain/Entities`,
screens in `MT-Screens`, and routes/factories in `MT-Factory`. Preserve those
roots while applying the same ownership rules.

## Placement guide

| Code | Owner |
| --- | --- |
| Business entity/value type | `Domain/Entities` |
| Repository protocol | `Domain/Repositories` |
| Business operation | `Domain/UseCases` |
| API response, DTO, database record | `Data/DTOs` or `Data/DataSources` |
| DTO-to-entity conversion | `Data/Mappers` |
| Repository implementation | `Data/Repositories` |
| API, disk, UserDefaults, SwiftData adapter | `Data/DataSources` or `Data/Services` |
| SwiftUI View | `Presentation/Views` |
| MVI Container/ObservableObject | `Presentation/Containers` |
| UIKit bridge or representable | `Presentation/Representables` |
| UI-only Color, Font, Image, formatting | `Presentation` or shared UI infrastructure |
| Route or coordinator | `Navigation` or established `MT-Factory` routing |
| Concrete dependency construction | `DI` or established Factory registration |

## Rules

- Use `Created by Vu The Anh` in generated or updated file headers.
- Views render state and send intents; keep networking, persistence, SDK
  ownership, and business rules outside Views.
- Containers consume use cases when a domain layer exists; never inject a
  concrete Data service or repository into a screen.
- Put repository protocols in Domain and implementations in Data.
- Keep Domain independent of SwiftUI, UIKit, persistence frameworks,
  networking clients, platform managers, and concrete SDKs.
- Keep DTOs, database records, API responses, and mappers in Data; expose
  domain entities across the Domain boundary.
- Keep UI-only colors, fonts, images, formatting, and view extensions in
  Presentation or shared UI infrastructure, not Domain.
- Prefer router abstractions over direct presentation hacks.
- Keep push destinations on the originating router stack. Sheet content
  self-dismisses with `@Environment(\.dismiss)`; the presenting router owns
  `dismissSheet()`.
- Keep feature-specific code near its feature and app-wide primitives in the
  existing shared Base folders.
- Avoid broad refactors unless they directly support the requested change.

## Anti-patterns

- Do not put repository protocols beside implementations in Data.
- Do not return SwiftUI or UIKit types from Domain.
- Do not leak DTOs or database records into Presentation.
- Do not let a Container instantiate repositories, API clients, or storage
  backends.
- Do not mix unrelated feature DTOs, entities, and presentation items in one
  global `Models` folder.
- Do not add a pass-through use case or empty layer only to match a diagram.

## Validation

- Confirm every dependency crosses toward Domain abstractions.
- Search Domain for forbidden UI, persistence, network, and SDK imports.
- Confirm View/Container code does not construct concrete Data dependencies.
- Check Factory keys, routes, parameters, and injected types match.
- Inspect `push -> sheet -> dismiss -> Back` after navigation changes; report
  runtime verification only when actually exercised on an authorized device.
- Run focused behavior tests for changed contracts where available, then
  `git diff --check` and one `generic/platform=iOS` workspace build after the
  coherent change. Repeat after fixes/new changes; no automatic Simulator.
