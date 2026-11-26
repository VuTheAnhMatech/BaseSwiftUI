// Created by Vu The Anh

import Foundation

@MainActor
struct ScreenDIFactory {
    let makeLoadHomePosts: () -> any LoadHomePostsUseCase

    func makeSplashContainer() -> SplashContainer { SplashContainer() }
    func makeHomeContainer() -> HomeContainer { HomeContainer(loadPosts: makeLoadHomePosts()) }
    func makeTranslationDemoContainer(showPaywall: Bool = false) -> TranslationDemoContainer {
        TranslationDemoContainer(showPaywall: showPaywall)
    }
    func makeWallpaperPaywallContainer() -> WallpaperPaywallContainer { WallpaperPaywallContainer() }
}
