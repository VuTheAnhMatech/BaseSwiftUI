// Created by Vu The Anh

import Factory
import SwiftUI

extension Container {
    var wallpaperPaywallContainer: Factory<WallpaperPaywallContainer> {
        self { MainActor.assumeIsolated { WallpaperPaywallContainer() } }
    }

    @MainActor
    func wallpaperPaywallView(onClose: @escaping () -> Void) -> some View {
        WallpaperPaywallView(container: self.wallpaperPaywallContainer(), onClose: onClose)
    }
}
