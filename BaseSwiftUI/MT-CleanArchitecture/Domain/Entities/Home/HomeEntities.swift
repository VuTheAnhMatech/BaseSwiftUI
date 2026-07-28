//
//  HomeEntities.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Foundation

struct HomeItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let symbol: String

    init(id: UUID = UUID(), title: String, subtitle: String, symbol: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
    }
}

extension HomeItem {
    static let defaults: [HomeItem] = [
        HomeItem(title: "MVI Container", subtitle: "State and intent stay outside the view.", symbol: "arrow.triangle.branch"),
        HomeItem(title: "Factory DI", subtitle: "Dependencies are registered in one place.", symbol: "shippingbox"),
        HomeItem(title: "Typed Router", subtitle: "Push, sheet and cover navigation are reusable.", symbol: "point.3.connected.trianglepath.dotted"),
        HomeItem(title: "BaseDataSource", subtitle: "Collections share consistent interaction hooks.", symbol: "square.grid.2x2")
    ]
}
