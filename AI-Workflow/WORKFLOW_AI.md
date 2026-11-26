# BaseSwiftUI Workflow

Use ProjMaker as the primary architecture reference, with BaseSwiftUI's full
Domain/UseCase/Repository/DTO, Network, DataSource and shared UI layers retained.
Use this file only for architecture/data-flow decisions.

## Sources of truth

- Architecture and ownership: `docs/architecture.md`
- MVI: `BaseSwiftUI/Core/Container/README.md`
- Routes: `BaseSwiftUI/Core/Navigation/README.md`
- DI: `BaseSwiftUI/Core/DI/README.md`
- Network: `BaseSwiftUI/Core/Network/Network_README.md`
- Lists: `BaseSwiftUI/Presentation/DataSource/BaseListView_README.md`

Read only the source relevant to the selected branch.

## Branch router

- `MVI`: State/Intent/Effect + Container + View with attachContainer lifecycle.
- `Clean`: `View → Container → UseCase → Repository → Service`; retain Domain
  repository protocols, Data implementations and DTO mapping.
- `Network`: request/auth/upload/decoding through Core/Network contracts.
- `DataSource`: Container/provider owns BaseDataSource; View renders it.
- `Mixed`: a flow crossing multiple branches.
- `Review`, `Trace`, `Security`, `Tooling`: use the matching specific skill.

## Invariants

- Views render state and forward intents. Containers implement dispatch and
  dispatchSystem, mutate through updateState, and send one-shot Effects.
- Views observe Effects and use Environment router. Containers do not own routers.
- AppRouteFactory maps AppRoute. AppDIFactory owns the Factory registry;
  registrations stay grouped by Service/Repository/UseCase, with ScreenDIFactory
  building Containers. No pass-through wrappers or Container.shared in UI.
- Each presentation owns its stack. Use the current router for push/pop/dismiss;
  native sheets can self-dismiss. asRoot replaces the complete navigation tree.
- Domain owns business entities, Data owns DTOs, Presentation owns UI-only items;
  defaults/mocks stay with their model. Repeated UI uses BaseDataSource.
- Preserve iOS 17, Swift 5, ObservableObject/Combine, Factory, CocoaPods, workspace,
  native iPhone/iPad support and all existing architectural layers.

## Finish gate

Check layer ownership, lifecycle/cancellation/effects, route/DI wiring and changed
flows. Run relevant host regressions and generic iOS workspace build. Simulator
validation requires an explicit user request. Report validation limits honestly.
