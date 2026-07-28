//
//  RoutePresentation.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

public enum RouteDragIndicatorVisibility: Hashable {
    case automatic
    case visible
    case hidden

    var swiftUIVisibility: Visibility {
        switch self {
        case .automatic:
            return .automatic
        case .visible:
            return .visible
        case .hidden:
            return .hidden
        }
    }
}

public enum RoutePresentation: Identifiable, Hashable {
    case page
    case fadeCover
    case fullscreenCover
    case sheet(
        detents: Set<PresentationDetent> = [PresentationDetent.large],
        dragIndicator: RouteDragIndicatorVisibility = .automatic
    )
    
    public var id: Self {
        return self
    }
}
