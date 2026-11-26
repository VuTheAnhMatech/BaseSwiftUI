// Created by Vu The Anh

import Foundation

enum SplashFeature: MVIFeature {
    struct State: DefaultInitializable {
        var title = AppInfo.appName
    }
    enum Intent { case start }
    enum Effect { case finished }
}

final class SplashContainer: BaseContainer<SplashFeature> {
    override func dispatch(_ intent: SplashFeature.Intent) async {
        switch intent {
        case .start:
            runTask(id: "splash", showsLoading: false) { [weak self] in
                do {
                    try await Task.sleep(for: .seconds(1.8))
                    try Task.checkCancellation()
                    self?.sendEffect(.finished)
                } catch {
                    // A later appearance starts a fresh splash task.
                }
            }
        }
    }

    override func dispatchSystem(_ intent: SystemIntent) async {
        if case .onAppear = intent { await dispatch(.start) }
    }
}
