//
//  BaseDataSource.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 2/4/26.
//

import SwiftUI
import Combine

@MainActor
class BaseDataSource<Item>: ObservableObject {
    @Published private(set) var listItem: [Item] = []

    let tappedItemSubject = PassthroughSubject<(Item?, IndexPath), Never>()
    let visibleItemSubject = PassthroughSubject<(Item?, IndexPath), Never>()
    let selectedValue = PassthroughSubject<Item, Never>()
    let visibleValue = PassthroughSubject<Item, Never>()

    func setListItem(_ list: [Item]) {
        listItem = list
    }

    func addListItem(_ list: [Item]) {
        listItem += list
    }

    func addItem(_ item: Item) {
        listItem.append(item)
    }

    func deleteItem(at index: Int) {
        guard listItem.indices.contains(index) else { return }
        listItem.remove(at: index)
    }

    func getItem(at index: Int) -> Item? {
        guard listItem.indices.contains(index) else { return nil }
        return listItem[index]
    }

    func reloadLayout() {
        objectWillChange.send()
    }

    func reloadItem(at indexPath: IndexPath) {
        guard listItem.indices.contains(indexPath.row) else { return }
        objectWillChange.send()
    }

    func selectedItem(at indexPath: IndexPath) {
        let item = getItem(at: indexPath.row)
        if let item { selectedValue.send(item) }
        tappedItemSubject.send((item, indexPath))
    }

    func itemDidAppear(at indexPath: IndexPath) {
        let item = getItem(at: indexPath.row)
        if let item { visibleValue.send(item) }
        visibleItemSubject.send((item, indexPath))
    }
}

extension BaseDataSource where Item: Identifiable {
    /// Resolve the current source row by identity, even if a rendered row has moved.
    /// Events use the latest stored value. Removed items do not emit events.
    @discardableResult
    func select(_ item: Item, section: Int = 0) -> Item? {
        guard let index = listItem.firstIndex(where: { $0.id == item.id }) else { return nil }
        let currentItem = listItem[index]
        selectedItem(at: IndexPath(row: index, section: section))
        return currentItem
    }

    @discardableResult
    func markVisible(_ item: Item, section: Int = 0) -> Bool {
        guard let index = listItem.firstIndex(where: { $0.id == item.id }) else { return false }
        itemDidAppear(at: IndexPath(row: index, section: section))
        return true
    }
}
