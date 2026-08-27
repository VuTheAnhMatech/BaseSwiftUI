# Figma functional-flow mapping

Use for a parent Figma node, multiple screens, or a request to create a complete
feature/function flow rather than a visual-only screen.

## Build the flow contract first

Map design evidence into one compact table:

| Evidence | BaseSwiftUI owner |
| --- | --- |
| Screen/frame and visual state | SwiftUI View |
| User action | MVI Intent |
| Loading/empty/error/selected state | Feature State |
| Navigation/presentation edge | `AppNavigationRoute` + router owner |
| Business rule | UseCase when justified |
| API/persistence | Service/Repository boundary |
| Construction/input | Factory registration/builder |
| Repeated content | Entity + `BaseDataSource` |

Do not infer hidden business behavior from pixels. Mark missing transition,
validation, API, purchase, persistence, and error rules as assumptions or ask
only when the choice materially changes the flow.

## Implementation order

1. Inventory screens, overlays, sheets, reusable regions, and design states.
2. Draw route/presentation ownership and the happy/error/cancel paths.
3. Define Feature State and action-based Intents before building screen bodies.
4. Reuse Base components, assets, tokens, entities, and data-source views.
5. Add the smallest justified domain layers and wire Factory/routes once.
6. Implement in navigable slices; keep each slice buildable and visually
   comparable to its Figma frame.
7. Validate the complete path, including back, sheet dismissal, retry,
   duplicate taps, empty/error, compact width, long text, and accessibility.

## Fidelity loop

For each screen, compare the running result or rendered preview to the Figma
screenshot. Record differences by hierarchy, asset, typography, spacing,
color, radius, safe area, and interaction state. Fix the largest visual or flow
break first; do not rewrite architecture to chase a cosmetic delta.
