// Created by Vu The Anh

import Factory
import SwiftUI

/// Keep Translate mounted so its safe-area bar is laid out before and after IAP.
struct WallpaperPaywallDemoHost: View {
    @State private var showsPaywall = true

    var body: some View {
        Container.shared.translationDemoView()
            .fullScreenCover(isPresented: $showsPaywall) {
                WallpaperPaywallDemoPresentation()
            }
    }
}
