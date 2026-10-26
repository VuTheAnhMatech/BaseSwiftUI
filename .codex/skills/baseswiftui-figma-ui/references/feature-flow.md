# Figma functional-flow mapping

Use for multiple screens, changed shared contracts, or new domain/data/network
behavior. One screen with routine Container/items/route/Factory uses `screen`.

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

Compare source against the Figma screenshot first. Compare a running result
only when runtime access is available and authorized; Simulator needs explicit
user request. Record differences by hierarchy, asset, typography, spacing,
color, radius, safe area, and interaction state. Fix the largest visual or flow
break first; do not rewrite architecture to chase a cosmetic delta.
