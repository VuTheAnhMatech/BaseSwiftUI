// Created by Vu The Anh

import Factory

@MainActor
struct ScreenDIFactory {
    // Retain the app-owned registry for future UseCase initializer injection.
    // Splash and Home have no data dependencies and resolve no services.
    let registry: Container

    func makeSplashContainer() -> SplashContainer { SplashContainer() }
    func makeHomeContainer() -> HomeContainer { HomeContainer() }
}
