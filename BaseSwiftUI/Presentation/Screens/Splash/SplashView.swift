// Created by Vu The Anh

import SwiftUI

struct SplashView: View {
    @StateObject var container: SplashContainer
    @Environment(\.router) private var router

    var body: some View {
        VStack(spacing: 12) {
            Text(container.state.title)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .attachContainer(container)
        .onReceive(container.effects) { effect in
            switch effect {
            case .finished:
                #if DEBUG
                router.navigate(to: .translationDemo(showPaywall: true), .asRoot)
                #else
                router.navigate(to: .home, .asRoot)
                #endif
            }
        }
    }
}

#Preview {
    SplashView(container: SplashContainer())
}
