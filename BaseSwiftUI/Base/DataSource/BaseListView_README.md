# BaseSwiftUI DataSource Views

Use `BaseDataSource` plus a Base data-source view for repeated feature UI. Raw
`ForEach`, `List`, `LazyVGrid`, and ad hoc `ScrollView` loops belong inside the
Base components, not feature views.

## Event flow

```text
SwiftUI feature View
  -> Base data-source View
  -> BaseDataSource
  -> tappedItemSubject / visibleItemSubject
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

```swift
final class HomeContainer: BaseRouteContainer<HomeFeature, AppNavigationRoute> {
    let dataSource = BaseDataSource<HomeItem>()

    override init() {
        super.init()

        dataSource.tappedItemSubject
            .compactMap(\.0)
            .sink { [weak self] item in self?.send(.select(item)) }
            .store(in: &cancellables)
    }

    override func handleIntent(_ intent: HomeFeature.Intent) {
        switch intent {
        case .load:
            dataSource.setListItem(HomeItem.defaults)
        case .select:
            router?.push(route: .detail)
        }
    }
}
```

## View rendering

```swift
BaseListView(dataSource: container.dataSource) { item in
    HomeRow(item: item)
}
```

Selection already sends through `BaseDataSource.selectedItem(at:)`; prefer the
Container subscription as the single behavior owner. Use `onSelect` only for a
small UI-local response that does not duplicate domain/navigation behavior.

## Index and filtering rules

- Base views preserve the source-array row in emitted `IndexPath` values even
  when `itemFilter` is used.
- Mutate data only through `BaseDataSource` methods or its owning Container.
- Keep default/static lists with their entity under
  `MT-CleanArchitecture/Domain/Entities`, not in the View.
- Keep a constant top-level row shape and stable identity for smooth diffing.
- Keep fixed overlays/footers from covering the final item by providing the
  required bottom content inset at the owning layout.
