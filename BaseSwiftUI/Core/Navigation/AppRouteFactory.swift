// Created by Vu The Anh

import SwiftUI

@MainActor
enum AppRouteFactory {
    @ViewBuilder
    static func make(route: AppRoute, diFactory: AppDIFactory) -> some View {
        switch route {
        case .splash:
            SplashView(container: diFactory.screens.makeSplashContainer())
        case .home:
            HomeView(container: diFactory.screens.makeHomeContainer())
        case .detail(let item):
            HomeDetailView(item: item)
        case .translationDemo(let showPaywall):
            TranslationDemoView(container: diFactory.screens.makeTranslationDemoContainer(showPaywall: showPaywall))
                .toolbar(.hidden, for: .navigationBar)
        case .wallpaperPaywall:
            WallpaperPaywallScreen(container: diFactory.screens.makeWallpaperPaywallContainer())
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}
