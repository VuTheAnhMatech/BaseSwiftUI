//
//  FactoryContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Factory

@MainActor
extension Container {
    // Factory stores synchronous @Sendable closures. Resolve UI containers on MainActor,
    // as FactoryView does; assumeIsolated enforces that boundary at construction.
    var splashContainer: Factory<SplashContainer> {
        self { MainActor.assumeIsolated { SplashContainer() } }
    }

    var homeContainer: Factory<HomeContainer> {
        self { MainActor.assumeIsolated { HomeContainer(loadPosts: self.loadHomePosts()) } }
    }
}
