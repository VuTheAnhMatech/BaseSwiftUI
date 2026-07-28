//
//  BaseStackView.swift
//  BaseSwiftUI
//

import SwiftUI

struct BaseStackView<
    Item,
    Content: View,
    DataSourceType: BaseDataSource<Item>
>: View where Item: Identifiable {

    enum AxisMode {
        case vertical
        case horizontal
    }

    @ObservedObject var dataSource: DataSourceType
    let axis: AxisMode
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let distributesItemsEqually: Bool
    let section: Int
    let itemFilter: (Item) -> Bool
    let content: (Item) -> Content
    let onSelect: ((Item) -> Void)?

    init(
        dataSource: DataSourceType,
        axis: AxisMode = .vertical,
        spacing: CGFloat = 0,
        alignment: HorizontalAlignment = .leading,
        distributesItemsEqually: Bool = false,
        section: Int = 0,
        itemFilter: @escaping (Item) -> Bool = { _ in true },
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.dataSource = dataSource
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distributesItemsEqually = distributesItemsEqually
        self.section = section
        self.itemFilter = itemFilter
        self.onSelect = onSelect
        self.content = content
    }

    var body: some View {
        switch axis {
        case .vertical:
            verticalContent
        case .horizontal:
            horizontalContent
        }
    }

    private var filteredItems: [(offset: Int, element: Item)] {
        Array(dataSource.listItem.enumerated()).filter { itemFilter($0.element) }
    }

    private var verticalContent: some View {
        Group {
            if distributesItemsEqually {
                GeometryReader { proxy in
                    VStack(alignment: alignment, spacing: spacing) {
                        cells(itemLength: equalItemLength(in: proxy.size.height))
                    }
                }
            } else {
                LazyVStack(alignment: alignment, spacing: spacing) {
                    cells()
                }
            }
        }
    }

    private var horizontalContent: some View {
        Group {
            if distributesItemsEqually {
                GeometryReader { proxy in
                    HStack(spacing: spacing) {
                        cells(itemLength: equalItemLength(in: proxy.size.width))
                    }
                }
            } else {
                HStack(spacing: spacing) {
                    cells()
                }
            }
        }
    }

    private func equalItemLength(in availableLength: CGFloat) -> CGFloat? {
        guard distributesItemsEqually, filteredItems.isEmpty == false else { return nil }

        let totalSpacing = spacing * CGFloat(max(filteredItems.count - 1, 0))
        return max((availableLength - totalSpacing) / CGFloat(filteredItems.count), 0)
    }

    @ViewBuilder
    private func cells(itemLength: CGFloat? = nil) -> some View {
        ForEach(filteredItems, id: \.element.id) { sourceIndex, item in
            content(item)
                .frame(
                    width: axis == .horizontal ? itemLength : nil,
                    height: axis == .vertical ? itemLength : nil
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    dataSource.selectedItem(at: IndexPath(row: sourceIndex, section: section))
                    onSelect?(item)
                }
                .onAppear {
                    dataSource.itemDidAppear(at: IndexPath(row: sourceIndex, section: section))
                }
        }
    }
}
