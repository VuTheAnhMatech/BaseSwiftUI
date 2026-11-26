// Created by Vu The Anh

import SwiftUI

enum PresentStyle: Hashable {
    case push, sheet, modal, fadeCover, asRoot
}

struct SheetConfiguration {
    var detents: Set<PresentationDetent> = [.large]
    var dragIndicator: Visibility = .automatic
    var selectedDetent: PresentationDetent?
}

struct AppRouter {
    var navigateHandler: @MainActor (AppRoute, PresentStyle, SheetConfiguration, (() -> Void)?) -> Void = { _, _, _, _ in }
    var popHandler: @MainActor (AppRouteKey) -> Void = { _ in }
    var backHandler: @MainActor (Int) -> Void = { _ in }
    var canGoBackHandler: @MainActor (Int) -> Bool = { _ in false }
    var resetHandler: @MainActor () -> Void = {}
    var dismissHandler: @MainActor () -> Void = {}
    var sheetConfigurationHandler: @MainActor (SheetConfiguration) -> Void = { _ in }
    var sheetSelectionHandler: @MainActor (PresentationDetent) -> Void = { _ in }
    var sheetSelection: @MainActor () -> PresentationDetent? = { nil }

    @MainActor
    func navigate(to route: AppRoute, _ style: PresentStyle = .push,
                  sheet: SheetConfiguration = SheetConfiguration(), onDismiss: (() -> Void)? = nil) {
        navigateHandler(route, style, sheet, onDismiss)
    }
    @MainActor func pop(to key: AppRouteKey) { popHandler(key) }
    @MainActor func goBack(_ count: Int = 1) { backHandler(count) }
    @MainActor func canGoBack(_ count: Int = 1) -> Bool { canGoBackHandler(count) }
    @MainActor func reset() { resetHandler() }
    @MainActor func dismiss() { dismissHandler() }
    @MainActor func updateSheet(_ configuration: SheetConfiguration) { sheetConfigurationHandler(configuration) }
    @MainActor func selectSheetDetent(_ detent: PresentationDetent) { sheetSelectionHandler(detent) }
    @MainActor var selectedSheetDetent: PresentationDetent? { sheetSelection() }
}

private struct AppRouterKey: EnvironmentKey {
    static let defaultValue = AppRouter()
}

extension EnvironmentValues {
    var router: AppRouter {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
