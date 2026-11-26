//
//  BaseLoadingView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 29/5/26.
//

import SwiftUI

struct BaseLoadingOverlayView: View {
    let backgroundOpacity: CGFloat
    let scale: CGFloat

    init(backgroundOpacity: CGFloat = 0.2, scale: CGFloat = 1.2) {
        self.backgroundOpacity = backgroundOpacity
        self.scale = scale
    }

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(scale)
        }
    }
}

struct BaseImageLoadingPlaceholder: View {
    let indicatorScale: CGFloat

    init(indicatorScale: CGFloat = 0.8) {
        self.indicatorScale = indicatorScale
    }

    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.white)
            .scaleEffect(indicatorScale)
    }
}

extension View {
    @ViewBuilder
    func baseLoadingOverlay(
        isLoading: Bool,
        backgroundOpacity: CGFloat = 0.2,
        scale: CGFloat = 1.2
    ) -> some View {
        ZStack {
            self
            if isLoading {
                BaseLoadingOverlayView(
                    backgroundOpacity: backgroundOpacity,
                    scale: scale
                )
            }
        }
    }
}
