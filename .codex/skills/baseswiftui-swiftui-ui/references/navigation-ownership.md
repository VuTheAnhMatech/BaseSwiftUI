# Screen wiring and navigation ownership

Read for `screen` mode or changes to routes, sheets, covers, or dismissal.

## One screen using existing patterns

The selected UI or Figma skill remains primary. Multiple files alone do not
require architecture's model/guidelines references or the full workflow.

1. Read one nearest feature and only the route/Factory definitions involved.
   Mirror construction and router injection; do not introduce another pattern.
2. Keep Feature/State/Intent with the Container. Put new UI-only items/defaults
   in a separate file under `MT-Screens/<Feature>`. Business entities stay in
   Domain; transport models stay in Data. Preserve legacy placement.
3. Let the Container own `BaseDataSource`; reuse the closest Base renderer.
   Read its API/contract only if needed. Reuse existing use cases when supplied;
   do not add repositories/use cases for static UI samples or selection state.
4. Add route mappings and Factory registrations together. Preserve parameters,
   scope, injected types, and the originating stack. Apply the dismissal
   contract below when relevant.
5. Before editing existing shared symbols, apply root GitNexus impact rules.
   This check alone does not change the primary skill. Escalate for changed
   shared contracts, dependency direction, or new source access/business
   behavior; Figma then uses `flow`.
6. Check state/intent wiring, model ownership, route/Factory consistency, and
   changed edges in source. Run `git diff --check` and one generic iOS build
   after the coherent edit. Fix compiler errors and rebuild; reuse DerivedData.
   No automatic tests, Simulator, or visual comparison for render/wiring-only
   work. Report runtime limits.

## Presentation ownership

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

Inspect `push → sheet → dismiss → Back` and each changed edge in source.
Exercise them only with authorized runtime access; Simulator requires explicit
user request. Report source inspection separately from runtime behavior.
