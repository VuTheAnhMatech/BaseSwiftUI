# SwiftUI interaction and content patterns

Read only the sections touched by the requested screen. These rules are adapted
to iOS 17 and the existing BaseSwiftUI architecture.

## Animation and transitions

- Bind implicit animation to an explicit value or animate the state mutation
  with `withAnimation`; avoid unscoped subtree animation.
- Keep transition identity stable and apply insertion/removal animation at the
  owner of the conditional content.
- Use phase/keyframe animation only when it communicates state better than a
  simple transition. Respect Reduce Motion and avoid layout-wide invalidation.

## Focus and keyboard

- Keep `@FocusState` private and model a single focus owner with a small enum
  for multi-field forms.
- Move focus on submit deliberately; clear it before dismissal when keyboard
  animation would conflict with presentation.
- Do not duplicate focus writes across gestures, `onAppear`, and Container
  state. Focus is view-local unless it is a real feature state.

## Scroll behavior

- Use stable item IDs for programmatic scrolling and keep the scroll target in
  the view layer unless it changes domain behavior.
- Avoid geometry feedback loops. Prefer iOS 17 scroll target/position APIs when
  they fit the existing Base data-source component.
- Preserve bottom insets under floating/sticky controls and test long content.

## Images

- Decode/downsample large data close to rendered size off the main thread;
  cache with bounded cost and cancellation.
- Treat `AsyncImage` as loading UI, not a complete production cache.
- Give meaningful images accessibility text and hide decorative images.

## Localization and text

- Keep user-facing strings localizable, preserve interpolation semantics, and
  use locale-aware formatters for dates, numbers, currency, and units.
- Test long translations, pluralization, right-to-left flow, and Dynamic Type.
- Avoid converting localized `Text` composition into a prebuilt `String` when
  that loses localization metadata.

## Swift Charts

- Import Charts only where used and keep chart data/models outside the View.
- Choose mark/scale/domain for the data meaning, not visual novelty.
- Provide an accessible chart descriptor or equivalent text summary and never
  encode series meaning by color alone.

## Previews

- Keep previews self-contained with deterministic local data and injected mock
  dependencies. Never call live network, purchase, persistence, or analytics.
- Cover compact width, large Dynamic Type, long localization, loading, empty,
  error, and meaningful dark-mode variants.
