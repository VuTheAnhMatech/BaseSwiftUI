//
//  SplashContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 28/7/26.
//

import Foundation

enum SplashFeature: MVIFeature {
    struct State: DefaultInitializable {
        var isPresented = false
        var isFinished = false
    }

    enum Intent {
        case appear
    }
}

final class SplashContainer: BaseContainer<SplashFeature> {
    override func handleIntent(_ intent: SplashFeature.Intent) {
        switch intent {
        case .appear:
            startSplashIfNeeded()
        }
    }

    private func startSplashIfNeeded() {
        guard !state.isPresented, !state.isFinished else { return }

        runTask(id: "splash", showsLoading: false) { [weak self] in
            self?.updateState { $0.isPresented = true }
            do {
                try await Task.sleep(for: .seconds(1.8))
                try Task.checkCancellation()
                self?.updateState { $0.isFinished = true }
            } catch {
                self?.updateState { $0.isPresented = false }
            }
        }
    }
}
