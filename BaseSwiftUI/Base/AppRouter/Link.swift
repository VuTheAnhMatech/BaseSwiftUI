//
//  Link.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

public extension AppRouter {
    struct Link<Content: View>: View {
        @EnvironmentObject var stack: StackController
        
        var route: Route
        var presentation: RoutePresentation
        
        let content: Content
        
        public init(
            to route: Route,
            presentation: RoutePresentation = .page,
            @ViewBuilder content: () -> Content
        ) {
            self.route = route
            self.presentation = presentation
            self.content = content()
        }
        
        public var body: some View {
            Button {
                stack.present(
                    route: self.route,
                    presentation: self.presentation
                )
            } label: {
                content
            }
            .buttonStyle(.plain)
        }
    }
}
