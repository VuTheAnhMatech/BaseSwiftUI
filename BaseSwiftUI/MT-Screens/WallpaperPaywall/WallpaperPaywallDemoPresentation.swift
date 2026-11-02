// Created by Vu The Anh

import Factory
import SwiftUI

/// The initial demo and Settings use the same presentation/dismissal boundary.
struct WallpaperPaywallDemoPresentation: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Container.shared.wallpaperPaywallView { dismiss() }
            .presentationBackground(Color(.WallpaperPaywall.surface))
    }
}
