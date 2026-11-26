// Created by Vu The Anh

import Combine
import Foundation
import SwiftUI

@MainActor
final class NavigationNode: ObservableObject, Identifiable {
    let id = UUID()
    let route: AppRoute
    let presentation: PresentStyle?
    @Published var path: [AppRoute] = []
    @Published var sheet: NavigationNode? {
        didSet { queueDismissal(oldValue, replacement: sheet, style: .sheet) }
    }
    @Published var modal: NavigationNode? {
        didSet { queueDismissal(oldValue, replacement: modal, style: .modal) }
    }
    @Published var fadeCover: NavigationNode? {
        didSet { queueDismissal(oldValue, replacement: fadeCover, style: .fadeCover) }
    }
    @Published private(set) var sheetConfiguration = SheetConfiguration()
    @Published private(set) var selectedSheetDetent: PresentationDetent = .large
    private var pendingDismissals: [PresentStyle: [NavigationNode]] = [:]
    private var onDismiss: (() -> Void)?

    init(route: AppRoute, presentation: PresentStyle? = nil, onDismiss: (() -> Void)? = nil) {
        self.route = route
        self.presentation = presentation
        self.onDismiss = onDismiss
    }

    var canPresent: Bool {
        sheet == nil && modal == nil && fadeCover == nil && pendingDismissals.isEmpty
    }

    func updateSheet(_ configuration: SheetConfiguration) {
        guard !configuration.detents.isEmpty else { return }
        sheetConfiguration = configuration
        if let selected = configuration.selectedDetent, configuration.detents.contains(selected) {
            selectedSheetDetent = selected
        } else if !configuration.detents.contains(selectedSheetDetent) {
            selectedSheetDetent = configuration.detents.contains(.large) ? .large : configuration.detents.first!
        }
    }

    func selectSheetDetent(_ detent: PresentationDetent) {
        guard sheetConfiguration.detents.contains(detent) else { return }
        selectedSheetDetent = detent
    }

    func contains(_ node: NavigationNode) -> Bool {
        self === node || sheet?.contains(node) == true || modal?.contains(node) == true
            || fadeCover?.contains(node) == true
    }

    func remove(_ node: NavigationNode) {
        if sheet === node { sheet = nil }
        else if modal === node { modal = nil }
        else if fadeCover === node { fadeCover = nil }
        else {
            sheet?.remove(node)
            modal?.remove(node)
            fadeCover?.remove(node)
        }
    }

    // Called by SwiftUI's native dismissal completion, or fade content disappearance.
    func presentationDidDismiss(_ style: PresentStyle) {
        let dismissed = pendingDismissals.removeValue(forKey: style) ?? []
        dismissed.forEach { $0.finishDismissal() }
    }

    func finishDismissal() {
        let callback = onDismiss
        onDismiss = nil
        let descendants = [sheet, modal, fadeCover].compactMap { $0 }
            + pendingDismissals.values.flatMap { $0 }
        pendingDismissals.removeAll()
        descendants.forEach { $0.finishDismissal() }
        callback?()
    }

    private func queueDismissal(_ old: NavigationNode?, replacement: NavigationNode?, style: PresentStyle) {
        guard let old, old !== replacement else { return }
        pendingDismissals[style, default: []].append(old)
    }
}

@MainActor
final class AppNavigationState: ObservableObject {
    @Published private(set) var root: NavigationNode

    init(root: AppRoute = .splash) { self.root = NavigationNode(route: root) }

    func router(for node: NavigationNode) -> AppRouter {
        AppRouter(
            navigateHandler: { [weak self, weak node] route, style, configuration, onDismiss in
                guard let self, let node, self.root.contains(node) else { return }
                self.navigate(to: route, style: style, from: node, sheet: configuration, onDismiss: onDismiss)
            },
            popHandler: { [weak self, weak node] key in
                guard let self, let node, self.root.contains(node) else { return }
                if let index = node.path.lastIndex(where: { $0.key == key }) {
                    node.path.removeSubrange((index + 1)..<node.path.count)
                } else if node.route.key == key {
                    node.path.removeAll()
                }
            },
            backHandler: { [weak self, weak node] count in
                guard let self, let node, self.root.contains(node), count > 0 else { return }
                if node.path.isEmpty, count == 1 { self.root.remove(node) }
                else if count <= node.path.count { node.path.removeLast(count) }
            },
            canGoBackHandler: { [weak self, weak node] count in
                guard let self, let node, self.root.contains(node) else { return false }
                return count > 0 && count <= node.path.count
            },
            resetHandler: { [weak self, weak node] in
                guard let self, let node, self.root.contains(node) else { return }
                node.path.removeAll()
            },
            dismissHandler: { [weak self, weak node] in
                guard let self, let node else { return }
                self.root.remove(node)
            },
            sheetConfigurationHandler: { [weak self, weak node] configuration in
                guard let self, let node, self.root.contains(node), node.presentation == .sheet else { return }
                node.updateSheet(configuration)
            },
            sheetSelectionHandler: { [weak self, weak node] detent in
                guard let self, let node, self.root.contains(node), node.presentation == .sheet else { return }
                node.selectSheetDetent(detent)
            },
            sheetSelection: { [weak self, weak node] in
                guard let self, let node, self.root.contains(node), node.presentation == .sheet else { return nil }
                return node.selectedSheetDetent
            }
        )
    }

    private func navigate(to route: AppRoute, style: PresentStyle, from node: NavigationNode,
                          sheet: SheetConfiguration, onDismiss: (() -> Void)?) {
        switch style {
        case .push:
            node.path.append(route)
        case .asRoot:
            let previous = root
            root = NavigationNode(route: route)
            previous.finishDismissal()
        case .sheet, .modal, .fadeCover:
            guard node.canPresent else { return }
            let presented = NavigationNode(route: route, presentation: style, onDismiss: onDismiss)
            presented.updateSheet(sheet)
            switch style {
            case .sheet: node.sheet = presented
            case .modal: node.modal = presented
            case .fadeCover: node.fadeCover = presented
            default: break
            }
        }
    }
}
