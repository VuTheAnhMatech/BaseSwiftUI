//
//  FactoryView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Factory
import SwiftUI

extension Container {
    @MainActor
    func splashView(onFinished: @escaping () -> Void) -> some View {
        SplashView(
            container: self.splashContainer(),
            onFinished: onFinished
        )
    }

    @MainActor
    func homeView() -> some View {
        HomeView(container: self.homeContainer())
    }
}
