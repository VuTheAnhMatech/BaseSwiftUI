//
//  Route.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

public protocol AppRoute: Identifiable, Hashable, Codable {
    associatedtype RouteView: View

    @MainActor
    var content: RouteView { get }
}
