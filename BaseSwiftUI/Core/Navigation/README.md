# Navigation

`AppRoute` contains route data; `AppRouteFactory` maps it to screens using DI.
`AppNavigationHost` owns the root tree. Each presented node owns its path.

```swift
@Environment(\.router) private var router

router.navigate(to: .home, .push)
router.navigate(to: .home, .sheet)
router.navigate(to: .wallpaperPaywall, .modal)
router.navigate(to: .home, .fadeCover)
router.navigate(to: .home, .asRoot)
router.pop(to: .home)
router.goBack(2)
router.canGoBack(2)
router.reset()
router.dismiss()
```

- Push and pop operate on the originating node. `pop(to:)` finds the last matching
  route key, ignoring associated values, or clears to the node's root route.
- Sheet, modal and fade cover each create a child with its own NavigationStack.
  Nested presentations use that child's router; no deepest-node lookup.
- `goBack(_:)` removes the requested number of pushed routes. Nonpositive or
  oversized counts do nothing. At a presented root, `goBack()` dismisses that node.
  `canGoBack(_:)` checks the pushed path only; `reset()` clears that path.
- `dismiss` removes the current presentation, including fade covers. Native
  sheet/modal content can also use Environment dismiss; SwiftUI updates the
  owning binding. Never use native dismiss to close a fade overlay.
- `asRoot` replaces the full tree, clearing all pushed/presented routes. Routers
  captured from the old tree become inactive.
- `SheetConfiguration` supports detents, drag-indicator visibility and an optional
  selectedDetent. SwiftUI selection and router.selectedSheetDetent share the same
  state. updateSheet preserves the selection when valid; selectSheetDetent rejects
  a value outside the supported detents. Empty sets are rejected/defaulted.
- navigate accepts onDismiss for sheet/modal/fade presentations. Native callbacks
  run once after SwiftUI onDismiss, fade callbacks after content disappearance.
  Nested callbacks run child-first. Root replacement completes detached callbacks
  immediately; later native completion cannot repeat them.
- Only one child presentation can open per node, including the dismissal interval.
  To open another after closing one, navigate from its onDismiss callback.

Containers emit effects; Views execute navigation. Do not inject routers into
Containers or construct screen dependencies in a View. Add cases to AppRoute
and AppRouteKey and map them once in AppRouteFactory.

The host regression script tests `push → sheet → push → Back → dismiss → Back`,
nested sheets/modal, fade dismiss and root replacement. Native gesture/animation
behavior still requires device validation; compile success is not a UI test.
