//
//  BaseDataSource.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 2/4/26.
//

import SwiftUI
import Combine

class BaseDataSource<Item>: ObservableObject {
    @Published private(set) var listItem: [Item] = []

    let tappedItemSubject = PassthroughSubject<(Item?, IndexPath), Never>()
    let visibleItemSubject = PassthroughSubject<(Item?, IndexPath), Never>()

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
        tappedItemSubject.send((item, indexPath))
    }

    func itemDidAppear(at indexPath: IndexPath) {
        let item = getItem(at: indexPath.row)
        visibleItemSubject.send((item, indexPath))
    }
}
