// Created by Vu The Anh

import Foundation

enum HomeFeature: MVIFeature {
    struct State: DefaultInitializable {
        var title = "Home"
    }

    typealias Intent = Never
}

@MainActor
final class HomeContainer: BaseContainer<HomeFeature> {
    override func dispatch(_ intent: Never) async {}
}
