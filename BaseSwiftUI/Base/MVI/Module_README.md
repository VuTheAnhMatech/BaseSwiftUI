# BaseSwiftUI MVI Module Guide

Use this guide when creating or reviewing a screen module. Mirror the nearest
feature first; `Home` is the current routed example and `Splash` is the current
non-routed example.

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
is an abstract-style trap and calls `fatalError` if an intent reaches it.

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
        BaseText(container.state.title)
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
            router?.push(route: .detail)
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
var profileContainer: Factory<ProfileContainer> {
    self { ProfileContainer() }
}
```

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
- Place reusable models/default data under
  `MT-CleanArchitecture/Domain/Entities/<Feature>/`.
- Keep the View render-only and forward interactions as intents.
- Keep async work cancellable and owned by the Container/use-case layer.
- Keep route cases, route content, factories, and injected types consistent.
- Build through `BaseSwiftUI.xcworkspace` after Swift changes.
