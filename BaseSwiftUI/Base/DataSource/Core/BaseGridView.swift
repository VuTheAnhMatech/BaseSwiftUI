//
//  BaseGridView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 15/4/26.
//

import SwiftUI

struct BaseGridView<
    Item,
    Content: View,
    DataSourceType: BaseDataSource<Item>
>: View where Item: Identifiable {

    @ObservedObject var dataSource: DataSourceType
    let columns: [GridItem]
    let spacing: CGFloat
    let itemAspectRatio: CGFloat?
    let isScrollEnabled: Bool
    let showsIndicators: Bool
    let contentInsets: EdgeInsets
    let scrollPosition: Binding<Item.ID?>?
    let section: Int
    let itemFilter: (Item) -> Bool
    let content: (Item) -> Content
    let onSelect: ((Item) -> Void)?

    init(
        dataSource: DataSourceType,
        columns: [GridItem],
        spacing: CGFloat = 12,
        itemAspectRatio: CGFloat? = nil,
        isScrollEnabled: Bool = false,
        showsIndicators: Bool = false,
        contentInsets: EdgeInsets = EdgeInsets(),
        scrollPosition: Binding<Item.ID?>? = nil,
        section: Int = 0,
        itemFilter: @escaping (Item) -> Bool = { _ in true },
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.dataSource = dataSource
        self.columns = columns
        self.spacing = spacing
        self.itemAspectRatio = itemAspectRatio
        self.isScrollEnabled = isScrollEnabled
        self.showsIndicators = showsIndicators
        self.contentInsets = contentInsets
        self.scrollPosition = scrollPosition
        self.section = section
        self.itemFilter = itemFilter
        self.onSelect = onSelect
        self.content = content
    }

    init(
        dataSource: DataSourceType,
        columnCount: Int,
        horizontalSpacing: CGFloat = 12,
        verticalSpacing: CGFloat = 12,
        itemAspectRatio: CGFloat? = nil,
        isScrollEnabled: Bool = false,
        showsIndicators: Bool = false,
        contentInsets: EdgeInsets = EdgeInsets(),
        scrollPosition: Binding<Item.ID?>? = nil,
        section: Int = 0,
        itemFilter: @escaping (Item) -> Bool = { _ in true },
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.dataSource = dataSource
        self.columns = Array(
            repeating: GridItem(.flexible(), spacing: horizontalSpacing),
            count: columnCount
        )
        self.spacing = verticalSpacing
        self.itemAspectRatio = itemAspectRatio
        self.isScrollEnabled = isScrollEnabled
        self.showsIndicators = showsIndicators
        self.contentInsets = contentInsets
        self.scrollPosition = scrollPosition
        self.section = section
        self.itemFilter = itemFilter
        self.onSelect = onSelect
        self.content = content
    }

    var body: some View {
        if isScrollEnabled {
            scrollableGrid
        } else {
            gridContent
        }
    }

    @ViewBuilder
    private var scrollableGrid: some View {
        if let scrollPosition {
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                gridContent
                    .scrollTargetLayout()
            }
            .scrollPosition(id: scrollPosition)
        } else {
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                gridContent
            }
        }
    }

    private var gridContent: some View {
        let filteredItems = Array(dataSource.listItem.enumerated()).filter { itemFilter($0.element) }

        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(filteredItems, id: \.element.id) { sourceIndex, item in
                sizedContent(item)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(contentInsets)
    }

    @ViewBuilder
    private func sizedContent(_ item: Item) -> some View {
        if let itemAspectRatio {
            Color.clear
                .aspectRatio(itemAspectRatio, contentMode: .fit)
                .overlay {
                    content(item)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
        } else {
            content(item)
        }
    }
}
