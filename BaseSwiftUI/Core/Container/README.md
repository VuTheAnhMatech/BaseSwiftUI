# Container: State – Intent – Effect

ProjMaker is the reference for dispatch, lifecycle and effects. BaseSwiftUI keeps
its MVIFeature grouping, read-only public state and stronger task ownership.

```swift
enum ProfileFeature: MVIFeature {
    struct State: DefaultInitializable { var title = "Profile" }
    enum Intent { case close }
    enum Effect { case dismiss }
}

final class ProfileContainer: BaseContainer<ProfileFeature> {
    override func dispatch(_ intent: ProfileFeature.Intent) async {
        switch intent {
        case .close: sendEffect(.dismiss)
        }
    }
}
```

A View owns its injected Container with `@StateObject`, renders `container.state`,
sends actions with `container.send`, attaches `.attachContainer(container)`, and
subscribes to `container.effects` with `.onReceive`. Effects are not replayed.
Use state for durable data; effects for navigation/dismissal/one-shot events.
A feature without effects may rely on the default `Effect = Never`.

## Lifecycle

Override `dispatchSystem(_:)` for `SystemIntent.onAppear`/`.onDisappear`.
Do not add lifecycle events to user Intent enums. ContainerConfig optionally
tracks color scheme and device orientation. The modifier sends all events through
`sendSystem`, never through untracked Tasks. Appear/disappear cancel the previous
visibility session synchronously, then enqueue their lifecycle event. Reappearance
must restart cancelled work when no result has been stored. Environment events
share the same ordered queue as user intents.

## Tasks and state

Containers are MainActor-isolated. Mutate via `updateState`; Views cannot assign
state. `send` and `sendSystem` return discardable task handles; await `.value` in
host tests. Intent/environment events run in enqueue order, even if a handler
suspends. A visibility transition cancels the old queue so a suspended old handler
does not block the new session. Keep dispatch handlers short; long service work
belongs in a stable `runTask(id:showsLoading:_:)` task.

Cancelled tasks cannot publish through `updateState`/`sendEffect` or register new
work. Continue checking cancellation before mutating other dependencies such as
BaseDataSource: cancellation cannot undo external side effects.

```swift
let useCase = loadPosts
runTask(id: "load") { [weak self] in
    do {
        let posts = try await useCase.execute()
        try Task.checkCancellation()
        self?.updateState { $0.posts = posts }
    } catch {
        guard !Task.isCancelled else { return }
        self?.updateState { $0.errorMessage = error.localizedDescription }
    }
}
```

The example assumes feature-specific state and a use case. `isLoading` is
derived from all loading tasks. Reusing an ID cancels the old task; its late
completion cannot clear the replacement. `runLoadingTask` creates independent
work. `cancelTask`, `cancelAllTasks`, disappearance and deinit cancel owned work.
Cancellation remains cooperative. Capture dependencies independently and the
Container weakly; check cancellation after suspension before publishing results.

## Dependencies and navigation

Inject UseCase protocols through the initializer. Construct Containers in
`Core/DI/ScreenDIFactory.swift`. Keep Service calls out of Containers and Views.
Emit a navigation Effect, then handle it in the View using Environment router.
See Home for the complete data flow and Splash for a local lifecycle/effect flow.
