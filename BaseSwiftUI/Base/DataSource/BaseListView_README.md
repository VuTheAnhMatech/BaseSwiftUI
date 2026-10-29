# BaseSwiftUI DataSource Views

Use `BaseDataSource` plus a Base data-source view for repeated feature UI. Raw
`ForEach`, `List`, `LazyVGrid`, and ad hoc `ScrollView` loops belong inside the
Base components, not feature views.

## Event flow

```text
SwiftUI feature View
  -> Base data-source View
  -> BaseDataSource
  -> selectedValue / visibleValue (or legacy index subjects)
  -> MVI Container
```

The Container owns the data source, loads data with `setListItem`, and binds
Combine subjects. The View observes the same instance and only supplies row or
cell rendering.

## Component selection

| Need | Component |
| --- | --- |
| Native vertical `List`, optional sections/styles | `BaseListView` |
| Lazy vertical list without native `List` chrome | `BaseLazyListView` |
| Vertical or horizontal carousel | `BaseScrollView` |
| Grid with columns/aspect ratio/optional scrolling | `BaseGridView` |
| Non-scrolling vertical or horizontal repeated stack | `BaseStackView` |
| Wrapping chips/tags | `BaseFlowView` |
| Vertical sections containing horizontal rows | `BaseHorizontalSectionListView` |

Items must be `Identifiable` with stable, unique IDs. Do not derive IDs from
mutable display fields or array positions.

## Container ownership

See `MT-Screens/Home/HomeContainer.swift` for the executable example: it receives
`LoadHomePostsUseCase`, maps domain posts into presentation `HomeItem` values,
updates its data source, and subscribes to `selectedValue` to send `.select`.
Selection pushes `.detail(item)` on the existing router. See
`docs/home-sample.md` for loading, errors, retry, cancellation, and DI.

## View rendering

```swift
BaseListView(dataSource: container.dataSource) { item in
    HomeRow(item: item)
}
```

Selection already sends through `BaseDataSource.select(_:section:)`; prefer the
Container subscription as the single behavior owner. Use `onSelect` only for a
small UI-local response that does not duplicate domain/navigation behavior.

## Index and filtering rules

- Base views preserve the source-array row in emitted `IndexPath` values even
  when `itemFilter` is used.
- `select(_:section:)` and `markVisible(_:section:)` resolve an item's stable
  ID against the current source array. Reordered items emit the latest stored
  value and current source index. `select` returns the resolved item (or `nil`
  for a removed item), so UI callbacks receive the same value as subscriptions.
  `markVisible` returns whether it found the item. Removed items emit nothing.
- `selectedValue` / `visibleValue` emit non-optional items. Each valid event
  also reaches `tappedItemSubject` / `visibleItemSubject` for existing consumers.
  Subscribe to one event family per action to avoid handling it twice.
- Existing `selectedItem(at:)` and `itemDidAppear(at:)` APIs retain their
  index-based behavior, including an optional nil item for an invalid row.
- Data-source mutations and events are isolated to `@MainActor`.
- Mutate data only through `BaseDataSource` methods or its owning Container.
- Keep defaults/static lists beside their owning model in its layer, not in
  the View or Container. Follow `MT-CleanArchitecture/README.md`: business
  models in Domain, transport models in Data, UI-only items in `MT-Screens`.
- Keep a constant top-level row shape and stable identity for smooth diffing.
- Keep fixed overlays/footers from covering the final item by providing the
  required bottom content inset at the owning layout.
