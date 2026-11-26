# Navigation and presentation ownership

Read only when changing routes, sheets, modal/fade covers or dismissal.
Use `BaseSwiftUI/Core/Navigation/README.md` as the current ProjMaker-first contract.

- Views use Environment router; Containers emit one-shot Effects.
- Push and pop stay on the originating navigation node.
- Every sheet/modal/fade child owns its own path and router.
- Current-node router.dismiss closes its presentation. Native sheet/modal Views
  may use Environment dismiss; fade overlays require router.dismiss.
- asRoot replaces the full tree; detached routers cannot mutate the new root.
- AppRoute contains data, AppRouteFactory maps it, ScreenDIFactory builds Containers.
- Never resolve Container.shared or inject a router into a Container.

Verify `push → sheet → push → Back → dismiss → Back` and affected nested routes
using state regressions. Native gesture/animation verification requires a device;
Simulator use requires an explicit user request.
