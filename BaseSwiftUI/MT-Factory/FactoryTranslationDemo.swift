// Created by Vu The Anh

import Factory
import SwiftUI

extension Container {
    var translationDemoContainer: Factory<TranslationDemoContainer> {
        self { MainActor.assumeIsolated { TranslationDemoContainer() } }
    }

    @MainActor
    func translationDemoView() -> some View {
        TranslationDemoView(container: self.translationDemoContainer())
    }
}
