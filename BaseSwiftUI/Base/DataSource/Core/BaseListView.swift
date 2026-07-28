//
//  BaseListView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 2/4/26.
//

import SwiftUI

enum BaseListViewStyle {
    case plain
    case grouped
    case insetGrouped
}

struct BaseListSection<Item>: Identifiable {
    let id: Int
    let section: Int
    let itemFilter: (Item) -> Bool
    let header: AnyView?

    init(
        id: Int,
        section: Int? = nil,
        itemFilter: @escaping (Item) -> Bool = { _ in true }
    ) {
        self.id = id
        self.section = section ?? id
        self.itemFilter = itemFilter
        self.header = nil
    }

    init<Header: View>(
        id: Int,
        section: Int? = nil,
        itemFilter: @escaping (Item) -> Bool = { _ in true },
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.id = id
        self.section = section ?? id
        self.itemFilter = itemFilter
        self.header = AnyView(header())
    }
}

struct BaseListView<
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
    let listStyle: BaseListViewStyle

    init(
        dataSource: DataSourceType,
        isFullRowTappable: Bool = true,
        section: Int = 0,
        itemFilter: @escaping (Item) -> Bool = { _ in true },
        listStyle: BaseListViewStyle = .plain,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.dataSource = dataSource
        self.section = section
        self.itemFilter = itemFilter
        self.sections = []
        self.listStyle = listStyle
        self.onSelect = onSelect
        self.rowContent = rowContent
    }

    init(
        dataSource: DataSourceType,
        sections: [BaseListSection<Item>],
        listStyle: BaseListViewStyle = .grouped,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.dataSource = dataSource
        self.sections = sections
        self.section = 0
        self.itemFilter = { _ in true }
        self.listStyle = listStyle
        self.onSelect = onSelect
        self.rowContent = rowContent
    }

    var body: some View {
        styledList
    }

    private var styledList: AnyView {
        switch listStyle {
        case .plain:
            return AnyView(baseList.listStyle(.plain))
        case .grouped:
            return AnyView(baseList.listStyle(.grouped))
        case .insetGrouped:
            return AnyView(baseList.listStyle(.insetGrouped))
        }
    }

    @ViewBuilder
    private var baseList: some View {
        if sections.isEmpty {
            List(filteredItems(itemFilter), id: \.element.id) { sourceIndex, item in
                row(item: item, sourceIndex: sourceIndex, section: section)
            }
        } else {
            List {
                ForEach(sections) { listSection in
                    Section {
                        ForEach(filteredItems(listSection.itemFilter), id: \.element.id) { sourceIndex, item in
                            row(item: item, sourceIndex: sourceIndex, section: listSection.section)
                        }
                    } header: {
                        if let header = listSection.header {
                            header.listRowInsets(EdgeInsets())
                        }
                    }
                }
            }
        }
    }
}

private extension BaseListView {
    func filteredItems(_ filter: (Item) -> Bool) -> [(offset: Int, element: Item)] {
        Array(dataSource.listItem.enumerated()).filter { filter($0.element) }
    }

    func row(item: Item, sourceIndex: Int, section: Int) -> some View {
        rowContent(item)
            .contentShape(Rectangle())
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onTapGesture {
                let indexPath = IndexPath(row: sourceIndex, section: section)
                dataSource.selectedItem(at: indexPath)
                onSelect?(item)
            }
            .onAppear {
                let indexPath = IndexPath(row: sourceIndex, section: section)
                dataSource.itemDidAppear(at: indexPath)
            }
    }
}
