# ProjMaker-first architecture

BaseSwiftUI uses ProjMaker 1.6.1 as the structural and runtime reference while
retaining its Domain, UseCase, repository protocol, DTO, network, persistence,
DataSource, shared UI, Factory, CocoaPods, iOS 17 and iPad support.

```text
BaseSwiftUI/
├── Core/
│   ├── App/          # App entry, delegate, composition root
│   ├── Container/    # State–Intent–Effect, lifecycle, cancellable tasks
│   ├── Navigation/   # AppRoute, AppRouteFactory, AppNavigationHost, router
│   ├── DI/           # App/Service/Repository/UseCase/Screen factories
│   ├── Network/      # Existing Alamofire transport/auth foundations
│   ├── CoreData/     # Existing persistence stack and model
│   └── Helpers/
├── Presentation/
│   ├── Screens/      # Feature View, Container and UI-only models
│   ├── Views/        # Shared Base UI components
│   └── DataSource/   # BaseDataSource and collection views
├── Domain/
│   ├── Entities/     # Framework-independent business models
│   ├── Repositories/ # Protocols consumed by use cases
│   └── UseCases/     # Business operations
├── Data/
│   ├── DTOs/         # API/storage transport models and small mappings
│   ├── Repositories/ # Domain repository implementations
│   └── Services/     # Remote/local data access, UserDefaults
├── Utils/            # AppInfo, Log, CodableUtil, Helpers, Extensions
├── Widgets/
├── Libs/
└── Resources/
```

## Flow and ownership

`View → Container → UseCase → Repository protocol → Repository implementation → Service`

The service decodes DTOs; the repository maps them to Domain entities. The
Container maps entities to UI items when needed. Views only render state and
send intents. UI-only screens need no empty data layers; existing layers are
never removed to imitate ProjMaker's smaller sample.

`MVIFeature` groups State, Intent and Effect. Containers implement async
`dispatch(_:)`, receive `SystemIntent` through `.attachContainer`, and publish
one-shot effects using `sendEffect`. Views subscribe with `.onReceive` and use
`@Environment(\.router)` for navigation. Containers never own routers.

`AppDIFactory` composes an app-owned Factory registry with ScreenDIFactory.
Service/Repository/UseCase registrations live in separate files extending that
registry directly, without duplicate wrapper objects. The App injects the factory
into AppNavigationHost; AppRouteFactory maps routes to screens. Services and
repositories use registry-local cached scope; Containers are fresh per screen.
Views never resolve Container.shared.

## Deliberate adaptations

- Keep Domain/UseCase/DTO and Factory instead of dropping existing layers.
- Keep the token-checked task manager: old completions cannot remove replacement
  tasks, concurrent loading is accurate, and owner deinit cancels tasks.
- Navigation binds a router to an exact presentation node. A sheet/modal owns
  its own path; nested sheets and modal-from-sheet work without guessing the
  deepest visible node. Fade covers and sheet detents remain supported.
- `asRoot` creates a fresh tree. Routers from detached nodes cannot navigate.
- Keep iOS 17, Swift 5, iPhone/iPad and CocoaPods. ProjMaker's Firebase project
  files and attribution SDKs are not dependencies of this architecture migration.
- Keep current assets, UI previews and the public API Home sample. Debug opens
  Translate with the paywall preview; Release opens Home after Splash.

## Source contracts

- `BaseSwiftUI/Core/Container/README.md`
- `BaseSwiftUI/Core/Navigation/README.md`
- `BaseSwiftUI/Core/DI/README.md`
- `BaseSwiftUI/Core/Network/Network_README.md`
- `BaseSwiftUI/Presentation/DataSource/BaseListView_README.md`

Business models belong in Domain, DTOs in Data, UI-only items in their feature;
defaults/mocks stay beside the model they describe. Do not put domain models
into Views or networking DTOs into Domain.

## Verification

Run `python3 scripts/test_core_behavior.py` for deterministic host-side checks
of effects, cancellation/replacement, loading, list identity, domain filtering,
Home's flow, public send/lifecycle ordering and cancellation, nested stacks,
dismiss callbacks, selected detents, multi-step back, DI and root replacement.
Storage tests use isolated doubles for secure save/delete/migration failures. These exercise
production state logic, not UIKit presentation animations. Build the workspace
for generic iOS; Simulator testing requires an explicit request.
