// Created by Vu The Anh

import SwiftUI

struct WallpaperPaywallScreen: View {
    @StateObject var container: WallpaperPaywallContainer
    @Environment(\.router) private var router

    var body: some View {
        WallpaperPaywallView(container: container) { router.dismiss() }
            .presentationBackground(Color(.WallpaperPaywall.surface))
    }
}
