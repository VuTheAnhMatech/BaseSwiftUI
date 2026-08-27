# BaseSwiftUI Workflow

Use this file for app-code architecture and data-flow decisions. Detailed UI,
IAP, Figma, widget, review, trace, security, and tooling procedures belong to
their specific skills.

## Sources of truth

- MVI: `BaseSwiftUI/Base/MVI/Module_README.md`
- Clean Architecture: `BaseSwiftUI/MT-CleanArchitecture/README.md`
- Network: `BaseSwiftUI/Base/Network/Network_README.md`
- Lists: `BaseSwiftUI/Base/DataSource/BaseListView_README.md`
- Navigation/DI: `BaseSwiftUI/MT-Factory/AppNavigationRoute.swift` and
  matching `Factory*.swift` files

Read only the source relevant to the selected branch.

## Branch router

- `MVI`: UI-only screen → `Feature + Container + View`, with Route/Factory
  only when needed.
- `Clean`: justified domain/data work →
  `Service → Repository → UseCase → Container → View`; omit empty layers.
- `Network`: API/auth/refresh/upload/decoding → Base request and API service
  contracts, then map responses before presentation.
- `DataSource`: repeated/list/grid/carousel UI → Container/provider owns
  `BaseDataSource`; View renders with the closest Base data-source view.
- `Mixed`: a complete feature or Figma flow crossing multiple branches.
- `Review`, `Trace`, `Security`, `Tooling`: use the matching specific skill;
  these branches do not authorize unrelated fixes.

## Invariants

- Views render state and forward action-named intents; no networking,
  persistence, or business rules in Views.
- Containers consume UseCases when a domain layer exists; screens never inject
  Services directly.
- New dependencies use matching Factory registrations. Add repository/use-case
  factories only when those layers exist.
- Routed screens add and map `AppNavigationRoute`, use the existing router, and
  keep Factory keys, route parameters, and injected types identical.
- Push destinations stay on the originating stack. Sheet content self-dismisses
  with `@Environment(\.dismiss)`; the presenting router owns `dismissSheet()`.
- Models, defaults, mock data, and list inputs belong under
  `MT-CleanArchitecture/Domain/Entities`; repeated UI uses `BaseDataSource`.

## Finish gate

Verify only what the change touched: render-only View, justified layers,
route/presentation ownership, Factory wiring, model placement, list ownership,
tests, and workspace build. Return changed files, validation evidence, and any
remaining uncertainty.
