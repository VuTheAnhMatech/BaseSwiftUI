# Modern SwiftUI for BaseSwiftUI

Apply these rules against the project's iOS 17 and Swift 5 baseline. They are
adapted from the reviewed upstream SwiftUI agent skills, not copied as an
unversioned mandate.

## State and data flow

- Keep a single source of truth. Use private `@State` for value state owned by
  the View, `@StateObject` for an `ObservableObject` the View owns, and
  `@ObservedObject` or the project's injection flow for an externally owned
  object.
- Preserve the current MVI Container as behavior owner. Views render state and
  send intents; networking, persistence, navigation decisions, and reusable
  data shaping stay outside `body`.
- Use `.task` or `.task(id:)` for lifecycle-bound async work so cancellation
  follows the View. Do not launch untracked work repeatedly from `body`.
- Treat Observation (`@Observable`, `@Bindable`) as a separate architecture
  migration. It is not an incidental review fix.

## API and structure

- Prefer `NavigationStack`/typed routes, `foregroundStyle`, modern
  `onChange` overloads, and shape-based clipping where they improve touched
  code and remain available on iOS 17.
- Use `Button` for actionable UI instead of `onTapGesture`; Button supplies
  keyboard, accessibility, pressed-state, and semantic behavior. Gesture use
  remains valid for gestures whose meaning is not a button activation.
- Keep `body` declarative and cheap. Extract coherent sections for readability,
  not every small expression, and do not hide simple layout literals in
  one-off constant containers.
- Do not use availability-unsafe APIs merely because an upstream skill targets
  the latest SDK.

## Identity, layout, and performance

- Every repeated item needs a stable, unique semantic ID. Avoid array indices,
  offsets, mutable display text, or regenerated UUIDs as identity.
- Use BaseDataSource plus the closest Base data-source view in feature screens.
  Keep item filtering, emitted source indices, and selection behavior aligned.
- Avoid sorting, filtering, formatters, image decoding, or object construction
  inside `body` when the result can be prepared by the Container or cached.
- Observe only the state needed by a view. Avoid broad invalidation and
  unnecessary `AnyView`; accept justified type erasure inside reusable Base
  infrastructure.
- Prefer flexible layout, Dynamic Type, and safe-area-aware overlays over
  device-size constants. Test compact width and long localized strings.
- Resize/decode large images to their rendered need and avoid animation that
  invalidates a larger hierarchy than necessary.

## Navigation and accessibility

- Keep page flows on their originating router stack. A sheet created by
  `ObservedStack.sheet` owns a nested router; its View should self-dismiss with
  `@Environment(\.dismiss)`, while only the presenting router owns
  `sheetRoute` and may call `dismissSheet()`.
- Give icon-only controls accessible labels, combine or hide child elements
  intentionally, preserve sufficient touch targets, and do not encode meaning
  with color alone.
- Verify VoiceOver order, Dynamic Type, Reduce Motion-sensitive animation, and
  localized text expansion for user-facing screens.

## Security baseline

- Authentication tokens and production credentials belong in Keychain or an
  approved secure store, not `UserDefaults`.
- Never log authorization headers, refresh tokens, credentials, or sensitive
  response bodies.

## Provenance

Adapted after security review from:

- `twostraws/swiftui-agent-skill`, commit `be297ff`
- `AvdLee/SwiftUI-Agent-Skill`, commit `4c6a97d`

Project deployment and architecture rules take precedence over upstream rules.
