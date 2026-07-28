//
//  SplashView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 28/7/26.
//

import SwiftUI

struct SplashView: View {
    @StateObject var container: SplashContainer
    let onFinished: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("BaseSwiftUI")
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            container.send(.appear)
        }
        .onChange(of: container.state.isFinished) { _, isFinished in
            guard isFinished else { return }
            onFinished()
        }
    }
}

#Preview {
    SplashView(container: SplashContainer()) {}
}
