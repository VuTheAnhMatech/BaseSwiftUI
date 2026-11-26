// Created by Vu The Anh

import SwiftUI

@MainActor
struct AppNavigationHost: View {
    let diFactory: AppDIFactory
    @StateObject private var navigation: AppNavigationState

    init(diFactory: AppDIFactory, root: AppRoute = .splash) {
        self.diFactory = diFactory
        _navigation = StateObject(wrappedValue: AppNavigationState(root: root))
    }

    var body: some View {
        NavigationNodeHost(node: navigation.root, navigation: navigation, diFactory: diFactory)
            .id(navigation.root.id)
    }
}

@MainActor
private struct NavigationNodeHost: View {
    @ObservedObject var node: NavigationNode
    let navigation: AppNavigationState
    let diFactory: AppDIFactory

    var body: some View {
        NavigationStack(path: $node.path) {
            destination(node.route)
                .navigationDestination(for: AppRoute.self) { destination($0) }
        }
        .environment(\.router, navigation.router(for: node))
        .tint(.primary)
        .sheet(item: $node.sheet, onDismiss: { node.presentationDidDismiss(.sheet) }) { child in
            SheetNodeHost(node: child, navigation: navigation, diFactory: diFactory)
        }
        .fullScreenCover(item: $node.modal, onDismiss: { node.presentationDidDismiss(.modal) }) { child in
            NavigationNodeHost(node: child, navigation: navigation, diFactory: diFactory)
        }
        .overlay {
            if let child = node.fadeCover {
                NavigationNodeHost(node: child, navigation: navigation, diFactory: diFactory)
                    .onDisappear { node.presentationDidDismiss(.fadeCover) }
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: node.fadeCover?.id)
    }

    private func destination(_ route: AppRoute) -> some View {
        AppRouteFactory.make(route: route, diFactory: diFactory)
            .environment(\.router, navigation.router(for: node))
            .navigationBarBackButtonHidden(true)
    }
}

@MainActor
private struct SheetNodeHost: View {
    @ObservedObject var node: NavigationNode
    let navigation: AppNavigationState
    let diFactory: AppDIFactory

    var body: some View {
        NavigationNodeHost(node: node, navigation: navigation, diFactory: diFactory)
            .presentationDetents(node.sheetConfiguration.detents, selection: Binding(
                get: { node.selectedSheetDetent },
                set: { node.selectSheetDetent($0) }
            ))
            .presentationDragIndicator(node.sheetConfiguration.dragIndicator)
    }
}
