# SwiftUI API baseline: iOS 17 / Swift 5

## Compiler-deprecated or superseded surfaces

| Candidate | Preferred iOS 17 surface | Review note |
| --- | --- | --- |
| `NavigationView` | `NavigationStack` or `NavigationSplitView` | Preserve typed router ownership; do not add a parallel stack. |
| `.navigationBarItems` | `.toolbar` | Recheck placement and accessibility. |
| `.actionSheet` | `.confirmationDialog` | Preserve destructive/cancel roles. |
| `.edgesIgnoringSafeArea` | `.ignoresSafeArea` | Recheck keyboard and container regions. |
| `.animation(_:)` | `.animation(_:value:)` or `withAnimation` | Scope animation to the actual state mutation. |
| old `.onChange(of:perform:)` closure form | iOS 17 zero/two-parameter overload | Preserve initial-value behavior explicitly. |

## Project-preferred, not automatic deprecations

- Prefer `foregroundStyle` when it preserves rendering intent; do not rewrite
  every `foregroundColor` without value.
- Prefer shape-based clipping over `cornerRadius` in touched code when it makes
  style/antialiasing explicit.
- Prefer `Button` over `onTapGesture` for activation semantics. Keep real
  gestures as gestures.
- Keep `ObservableObject`/Combine. Observation is an explicit architecture
  migration, not an API-cleanup side effect.

Every entry added here needs installed-SDK or official Apple evidence and an
availability statement.
