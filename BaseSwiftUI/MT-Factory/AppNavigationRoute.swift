//
//  AppNavigationRoute.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import SwiftUI
import Factory

typealias RouterController = AppRouter<AppNavigationRoute>

enum AppNavigationRoute: AppRoute {
    case home
    case detail

    var id: Self { self }

    @MainActor @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            Container.shared.homeView()
        case .detail:
            SampleDetailView()
        }
    }
}
