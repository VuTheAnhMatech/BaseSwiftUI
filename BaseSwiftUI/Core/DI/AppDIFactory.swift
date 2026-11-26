// Created by Vu The Anh

import Factory

@MainActor
final class AppDIFactory {
    let screens: ScreenDIFactory

    init(registry: Container = Container()) {
        screens = ScreenDIFactory(makeLoadHomePosts: { registry.loadHomePosts() })
    }
}
