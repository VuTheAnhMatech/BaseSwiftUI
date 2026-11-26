// Created by Vu The Anh

import Foundation

enum AppRoute: Hashable, Identifiable {
    case splash
    case home
    case detail(HomeItem)
    case translationDemo(showPaywall: Bool)
    case wallpaperPaywall

    var id: Self { self }
    var key: AppRouteKey {
        switch self {
        case .splash: return .splash
        case .home: return .home
        case .detail: return .detail
        case .translationDemo: return .translationDemo
        case .wallpaperPaywall: return .wallpaperPaywall
        }
    }
}

enum AppRouteKey {
    case splash, home, detail, translationDemo, wallpaperPaywall
}
