# WORKFLOW_AI

This file defines how AI should handle requests in this codebase.

## Source of truth

- `BaseSwiftUI/Base/MVI/Module_README.md`
- `BaseSwiftUI/MT-CleanArchitecture/README.md`
- `BaseSwiftUI/Base/Network/Network_README.md`
- `BaseSwiftUI/Base/DataSource/BaseListView_README.md`
- `BaseSwiftUI/Base/AppRouter/CustomRoute.swift`
- `BaseSwiftUI/MT-Factory/FactoryContainer.swift`
- `BaseSwiftUI/MT-Factory/FactoryView.swift`
- `BaseSwiftUI/MT-Factory/FactoryService.swift`
- `BaseSwiftUI/MT-Factory/FactoryRepository.swift`
- `BaseSwiftUI/MT-Factory/FactoryUseCase.swift`

## Request router

1. If request is UI module/screen creation, use MVI module flow:
   `Container + View + Route(optional) + Factory(optional)`.
2. If request is business/data feature, use Clean Architecture flow:
   `Service -> Repository -> UseCase -> Container/View`.
3. If request is API/auth/refresh/upload/decoding, use Network base flow:
   `BaseRequest/APIRequestType -> APIService -> Response mapping`.
4. If request is list/collection UI, use DataSource flow:
   `View -> BaseListView/BaseScrollView -> BaseDataSource -> Combine -> Container/ViewModel`.
5. If request includes navigation/DI, always update route and factories consistently.

## Hard rules

1. Screen layer injects `UseCase`, not `Service` directly (except pure UI-only module).
2. Service decision rule:
   If user provides service name, reuse it.
   If not, create `<Feature>Service`.
3. Always register DI in matching `Factory*` files for new dependencies.
4. Route-based screens use `BaseRouteContainer` and `.injectRouter(to:)`.
5. Keep View as render-only; logic lives in container/use case/repository.

## Design + Architecture compliance gates

1. Design gate (UI quality + responsibility):
   - View renders state and forwards intents only.
   - No API calls, persistence, or business rules inside View.
   - Intent names are action-based (`onAppear`, `didTap...`, `submit`, `open...`).
2. Clean Architecture gate:
   - Flow must remain `Service -> Repository -> UseCase -> Container/View`.
   - Container consumes `UseCase`; do not bypass layers.
   - Repository owns datasource/service calls and mapping.
3. Routing gate (when opening a new screen):
   - Add route case in `CustomRoute`.
   - Map route case in `content`.
   - Trigger navigation from container via `router.push(...)` or `router.present(...)`.
4. DI gate:
   - Register all new dependencies in matching `Factory*` files.
   - Factory keys, route parameters, and injected types must match exactly.

## Mandatory clarification gate (blocking)

Before editing code, if branch-specific implementation is possible and not explicitly stated, AI must ask one short yes/no question and wait for answer.

Trigger cases:
- Request mentions list/table/collection/grid items in a screen.
- AI must ask: "Do you want to implement this list using BaseListView/BaseDataSource (per BaseListView_README.md)?"

Fail-closed rule:
- AI must not start code changes until user answers this question.
- If user says "yes", DataSource flow is mandatory.
- If user says "no", AI must ask what alternative list pattern to use.

## Execution workflow per request

1. Parse request into `Feature`, `NeedsRoute`, `NeedsDI`, `ServiceName`.
2. Select workflow branch (MVI, Clean, Network, DataSource, or mixed).
3. Generate/update only required files.
4. Run compliance verification:
   - design gate
   - clean architecture gate
   - routing gate
   - DI gate
5. Verify route + factory keys + injected types are consistent.
6. Return changed files and key lines.
