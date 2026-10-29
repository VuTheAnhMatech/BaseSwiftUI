# BaseSwiftUI MVI Module Guide

Use this guide when creating or reviewing a screen module. Mirror the nearest
feature first; `Home` is the current routed API-backed example and `Splash` is
the current non-routed example. See `docs/home-sample.md` for Home's full flow,
dependency construction, lifecycle, and verification scenarios.

## Module shape

A module contains:

- a top-level `<Feature>Feature: MVIFeature` enum with nested `State` and `Intent`
- a `<Feature>Container` derived from `BaseContainer` or `BaseRouteContainer`
- a `<Feature>View` that owns the container with `@StateObject`
- Factory registrations/builders
- an `AppNavigationRoute` case when navigation is required

Keep `State` conforming to `DefaultInitializable`, intents action-based, and
business/network/persistence work outside the View.

Every concrete Container must override `handleIntent`. The Base implementation
is an abstract-style trap and calls `preconditionFailure` if an intent reaches it.

Containers and the `MVIContainer` contract are `@MainActor`. State is read-only
outside its owner; change it through `updateState { $0.property = value }` in
Container intent handlers or their helpers. Views continue to read state and
send intents.

## Async work

- `runTask(id:showsLoading:_:)` owns cancellable work by a stable ID. Reusing
  an ID cancels the old task; other IDs keep running. Completion of an older
  task cannot remove a newer task with the same ID.
- `runLoadingTask(_:)` remains available. Each call creates independent work,
  and loading stays visible until every registered loading task has finished
  or been cancelled through the Container.
- Use `cancelTask(id:)` or `cancelAllTasks()` when the owning flow no longer
  needs the work. Deinitialization cancels remaining tasks; view disappearance
  does not automatically mean the Container has been deinitialized.
- Capture the Container weakly and check cancellation after suspension before
  changing state. Avoid upgrading weak `self` to a strong reference across a
  long await. Cancellation is cooperative; the manager cannot stop a service
  that ignores it or undo side effects already performed.

```swift
runTask(id: "load") { [weak self] in
    do {
        let result = try await useCase.execute()
        try Task.checkCancellation()
        self?.updateState { $0.result = result }
    } catch {
        guard !Task.isCancelled else { return }
        self?.updateState { $0.errorMessage = error.localizedDescription }
    }
}
```

The example assumes a feature-specific `useCase`, `result`, and `errorMessage`.
`isLoading` is derived from registered tasks and cannot be set directly.

## Non-routed module

```swift
enum ProfileFeature: MVIFeature {
    struct State: DefaultInitializable {
        var title = "Profile"
    }

    enum Intent {
        case appear
        case didTapPrimary
    }
}

final class ProfileContainer: BaseContainer<ProfileFeature> {
    override func handleIntent(_ intent: ProfileFeature.Intent) {
        switch intent {
        case .appear:
            break
        case .didTapPrimary:
            break
        }
    }
}
```

```swift
struct ProfileView: View {
    @StateObject var container: ProfileContainer

    var body: some View {
        BaseText(container.state.title, font: .plusJakartaSansRegular, size: 17)
            .task { container.send(.appear) }
    }
}
```

## Routed module

Use `BaseRouteContainer<Feature, AppNavigationRoute>` and inject the router in
the view:

```swift
final class ProfileContainer: BaseRouteContainer<ProfileFeature, AppNavigationRoute> {
    override func handleIntent(_ intent: ProfileFeature.Intent) {
        switch intent {
        case .didTapPrimary:
            router?.push(route: .home)
        case .appear:
            break
        }
    }
}
```

```swift
ProfileView(container: container)
    .injectRouter(to: container)
```

Add the route and map its content in
`BaseSwiftUI/MT-Factory/AppNavigationRoute.swift`. Do not create a second
navigation abstraction.

## Factory wiring

Register the Container in `FactoryContainer.swift`:

```swift
@MainActor
var profileContainer: Factory<ProfileContainer> {
    self { MainActor.assumeIsolated { ProfileContainer() } }
}
```

Factory stores synchronous closures without actor isolation in the installed
version. Resolve these UI factories on MainActor; `MainActor.assumeIsolated`
checks that requirement when creating the Container.

Build the View using the current `@MainActor` function style in
`FactoryView.swift`:

```swift
@MainActor
func profileView() -> some View {
    ProfileView(container: self.profileContainer())
}
```

Use `ParameterFactory` only when the screen genuinely requires an input. Match
the nearest parameterized feature rather than inventing a default `String` ID.

## Checklist

- Place feature files under `BaseSwiftUI/MT-Screens/<Feature>/`.
- Follow `MT-CleanArchitecture/README.md` for model ownership: business entities
  in Domain, transport/storage models in Data, and UI-only items in separate
  files under `MT-Screens/<Feature>`. Defaults/mocks stay beside their owner in
  the same layer; keep them out of View bodies and Containers.
- Keep the View render-only and forward interactions as intents.
- Keep async work cancellable and owned by the Container/use-case layer.
- Keep route cases, route content, factories, and injected types consistent.
- Build through `BaseSwiftUI.xcworkspace` after Swift changes.
