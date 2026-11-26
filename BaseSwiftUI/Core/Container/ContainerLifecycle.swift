// Created by Vu The Anh

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum SystemIntent {
    case onAppear
    case onDisappear
    case colorSchemeChanged(ColorScheme)
    #if canImport(UIKit)
    case orientationChanged(UIDeviceOrientation)
    #endif
}

public struct ContainerConfig {
    public var trackAppear = true
    public var trackDisappear = true
    public var trackColorScheme = false
    public var trackOrientation = false

    public init(trackAppear: Bool = true, trackDisappear: Bool = true,
                trackColorScheme: Bool = false, trackOrientation: Bool = false) {
        self.trackAppear = trackAppear
        self.trackDisappear = trackDisappear
        self.trackColorScheme = trackColorScheme
        self.trackOrientation = trackOrientation
    }
}

@MainActor
private struct ContainerModifier<F: MVIFeature>: ViewModifier {
    let container: BaseContainer<F>
    let config: ContainerConfig
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .onAppear {
                if config.trackAppear { container.sendSystem(.onAppear) }
                if config.trackColorScheme { container.sendSystem(.colorSchemeChanged(colorScheme)) }
            }
            .onDisappear {
                guard config.trackDisappear else { return }
                container.sendSystem(.onDisappear)
            }
            .onChange(of: colorScheme) { _, value in
                guard config.trackColorScheme else { return }
                container.sendSystem(.colorSchemeChanged(value))
            }
            #if canImport(UIKit)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                guard config.trackOrientation else { return }
                container.sendSystem(.orientationChanged(UIDevice.current.orientation))
            }
            #endif
    }
}

extension View {
    @MainActor
    func attachContainer<F: MVIFeature>(
        _ container: BaseContainer<F>, config: ContainerConfig = ContainerConfig()
    ) -> some View {
        modifier(ContainerModifier(container: container, config: config))
    }
}
