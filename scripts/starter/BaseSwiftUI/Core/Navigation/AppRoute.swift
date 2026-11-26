// Created by Vu The Anh

import Foundation

enum AppRoute: Hashable, Identifiable {
    case splash
    case home

    var id: Self { self }
    var key: AppRouteKey {
        switch self {
        case .splash: return .splash
        case .home: return .home
        }
    }
}

enum AppRouteKey {
    case splash, home
}
