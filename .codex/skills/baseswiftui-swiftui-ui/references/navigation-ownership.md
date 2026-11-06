# Navigation and presentation ownership

Read this only when a UI task changes routes, sheets, full-screen covers, or
dismissal.

- Keep page destinations on the originating router stack. Do not re-present a
  pushed page inside a new full-screen stack unless ownership crosses a real
  root boundary.
- A route rendered by `ObservedStack.sheet` is wrapped in a nested
  `AppRouter.Stack`. Its injected router does not own the presenting stack's
  `sheetRoute`.
- Sheet content self-dismisses with `@Environment(\.dismiss)`. For async
  completion, Container state publishes a dismissal request and the View calls
  `dismiss()`.
- Only the presenting parent router calls `dismissSheet()`.
- Add and map the route using the existing `AppNavigationRoute` and Factory
  style. Keep route parameters, Factory keys, and injected types identical.

After editing, exercise `push → sheet → dismiss → Back` and any changed
presentation edge. Confirm one page stack, correct state restoration, and no
transition flash.
