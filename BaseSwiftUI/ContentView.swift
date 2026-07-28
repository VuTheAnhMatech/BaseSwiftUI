//
//  ContentView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import SwiftUI
import Factory

struct ContentView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            } else {
                RouterController.Stack {
                    Container.shared.homeView()
                }
                .transition(.opacity)
            }
        }
        .task {
            guard isShowingSplash else { return }

            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeInOut(duration: 0.45)) {
                isShowingSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
