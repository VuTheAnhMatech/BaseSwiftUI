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
        }
    }
}
