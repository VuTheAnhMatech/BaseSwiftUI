//
//  StackController.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import Combine
import SwiftUI

public extension AppRouter {
    struct SheetRoute: Identifiable {
        public var id: Route {
            self.route
        }
        
        let route: Route
        let presentation: Set<PresentationDetent>
        let dragIndicator: RouteDragIndicatorVisibility
        let onDismiss: (() -> Void)?
        
        public init(
            route: Route,
            presentation: Set<PresentationDetent>,
            dragIndicator: RouteDragIndicatorVisibility = .automatic,
            onDismiss: (() -> Void)? = nil
        ) {
            self.route = route
            self.presentation = presentation
            self.dragIndicator = dragIndicator
            self.onDismiss = onDismiss
        }
    }
}

public extension AppRouter {
    class StackController: ObservableObject {
        @Published
        var path: NavigationPath
        
        var currentRoute: Route? {
            Self.lastRoute(from: self.path)
        }
        
        @Published
        var sheetRoute: SheetRoute?

        @Published
        var selectedSheetPresentation: PresentationDetent = .large

        private var sheetDismissAction: (() -> Void)?
        
        @Published
        var fullScreenCoverRoute: Route?

        @Published
        var fadeCoverRoute: Route?
        
        var dismissStack: DismissAction
        
        public init(
            path: NavigationPath = NavigationPath(),
            dismiss: DismissAction
        ) {
            self.path = path
            self.dismissStack = dismiss
        }
        
        public func goBack(_ count: Int = 1) {
            guard canGoBack(count) else { return }

            self.path.removeLast(count)
        }
        
        public func reset() {
            self.path = .init()
        }
        
        public func canGoBack() -> Bool {
            self.path.isEmpty == false
        }

        public func canGoBack(_ count: Int) -> Bool {
            self.path.count >= count
        }
        
        public func push(route: Route) {
            self.path.append(route)
            print("new count: \(self.path.count)")
        }
        
        public func present(
            route: Route,
            with presentation: Set<PresentationDetent>,
            dragIndicator: RouteDragIndicatorVisibility = .automatic,
            onDismiss: (() -> Void)? = nil
        ) {
            self.sheetDismissAction = onDismiss
            self.selectedSheetPresentation = presentation.first ?? .large
            self.sheetRoute = .init(
                route: route,
                presentation: presentation,
                dragIndicator: dragIndicator,
                onDismiss: onDismiss
            )
        }

        public func present(
            route: Route,
            presentation: RoutePresentation,
            onDismiss: (() -> Void)? = nil
        ) {
            switch presentation {
            case .page:
                push(route: route)
            case .fadeCover:
                presentFadeCover(route: route)
            case .sheet(let detents, let dragIndicator):
                present(route: route, with: detents, dragIndicator: dragIndicator, onDismiss: onDismiss)
            case .fullscreenCover:
                presentFullScreenCover(route: route)
            }
        }

        public func presentFadeCover(route: Route) {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.fadeCoverRoute = route
            }
        }
        
        public func presentFullScreenCover(route: Route) {
            self.fullScreenCoverRoute = route
        }
        
        public func dismiss() {
            self.dismissStack()
        }
        
        public func dismissSheet() {
            guard self.sheetRoute != nil else {
                self.dismissStack()
                return
            }

            self.sheetRoute = nil
            performSheetDismissAction()
        }
        
        public func dismissFullScreenCover() {
            self.fullScreenCoverRoute = nil
        }

        public func dismissFadeCover() {
            withAnimation(.easeInOut(duration: 0.25)) {
                self.fadeCoverRoute = nil
            }
        }

        public func updateSheetPresentation(_ presentation: Set<PresentationDetent>) {
            guard let sheetRoute else { return }

            self.selectedSheetPresentation = presentation.first ?? .large
            self.sheetRoute = .init(
                route: sheetRoute.route,
                presentation: presentation,
                dragIndicator: sheetRoute.dragIndicator,
                onDismiss: sheetRoute.onDismiss
            )
        }
    }
}

public extension AppRouter.StackController {
    func handleSheetDismiss() {
        performSheetDismissAction()
    }

    private func performSheetDismissAction() {
        let action = sheetDismissAction
        sheetDismissAction = nil
        action?()
    }
}


extension AppRouter.StackController {
    // FIXME: Theres a way to clean this up a bit
    static func lastRoute(from path: NavigationPath) -> Route? {
        guard
            let pathData = try? JSONEncoder().encode(path.codable),
            let pathArr = try? JSONDecoder().decode([String].self, from: pathData),
            pathArr.count >= 2,
            let data = pathArr[1].data(using: .utf8),
            let route = try? JSONDecoder().decode(Route.self, from: data)
        else {
            return nil
        }
        
        return route
    }
}
