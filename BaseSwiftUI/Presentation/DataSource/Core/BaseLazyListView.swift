//
//  BaseLazyListView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 28/5/26.
//

import SwiftUI

struct BaseLazyListView<
    Item,
    RowContent: View,
    DataSourceType: BaseDataSource<Item>
>: View, CommonDataSourceView where Item: Identifiable {

    @ObservedObject var dataSource: DataSourceType
    let rowContent: (Item) -> RowContent
    let onSelect: ((Item) -> Void)?
    let section: Int
    let itemFilter: (Item) -> Bool
    let sections: [BaseListSection<Item>]
    let spacing: CGFloat
    let showsIndicators: Bool

    init(
        dataSource: DataSourceType,
        section: Int = 0,
        itemFilter: @escaping (Item) -> Bool = { _ in true },
        spacing: CGFloat = 0,
        showsIndicators: Bool = false,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.dataSource = dataSource
        self.section = section
        self.itemFilter = itemFilter
        self.sections = []
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.onSelect = onSelect
        self.rowContent = rowContent
    }

    init(
        dataSource: DataSourceType,
        sections: [BaseListSection<Item>],
        spacing: CGFloat = 0,
        showsIndicators: Bool = false,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.dataSource = dataSource
        self.sections = sections
        self.section = 0
        self.itemFilter = { _ in true }
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.onSelect = onSelect
        self.rowContent = rowContent
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            LazyVStack(alignment: .leading, spacing: spacing) {
                if sections.isEmpty {
                    ForEach(filteredItems(itemFilter)) { item in
                        row(item: item, section: section)
                    }
                } else {
                    ForEach(sections) { listSection in
                        if let header = listSection.header {
                            header
                        }

                        ForEach(filteredItems(listSection.itemFilter)) { item in
                            row(item: item, section: listSection.section)
                        }
                    }
                }
            }
        }
    }
}

private extension BaseLazyListView {
    func filteredItems(_ filter: (Item) -> Bool) -> [Item] {
        dataSource.listItem.filter(filter)
    }

    func row(item: Item, section: Int) -> some View {
        rowContent(item)
            .contentShape(Rectangle())
            .onTapGesture {
                if let selectedItem = dataSource.select(item, section: section) {
                    onSelect?(selectedItem)
                }
            }
            .onAppear {
                dataSource.markVisible(item, section: section)
            }
    }
}
