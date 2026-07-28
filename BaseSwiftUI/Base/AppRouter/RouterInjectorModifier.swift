//
//  RouterInjectorModifier.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 7/4/26.
//

import SwiftUI

struct SheetPresentationUpdaterKey: EnvironmentKey {
    static let defaultValue: ((Set<PresentationDetent>) -> Void)? = nil
}

extension EnvironmentValues {
    var sheetPresentationUpdater: ((Set<PresentationDetent>) -> Void)? {
        get { self[SheetPresentationUpdaterKey.self] }
        set { self[SheetPresentationUpdaterKey.self] = newValue }
    }
}

struct RouterInjectorModifier<F: MVIFeature, R: AppRoute>: ViewModifier {
    @EnvironmentObject var router: AppRouter<R>.StackController
    @Environment(\.sheetPresentationUpdater) private var sheetPresentationUpdater
    
    let container: BaseRouteContainer<F, R>

    func body(content: Content) -> some View {
        content.onAppear {
            container.router = router
            container.updateCurrentSheetPresentation = sheetPresentationUpdater
        }
    }
}

extension View {
    func injectRouter<F: MVIFeature, R: AppRoute>(to container: BaseRouteContainer<F, R>) -> some View {
        self.modifier(RouterInjectorModifier(container: container))
    }
}
