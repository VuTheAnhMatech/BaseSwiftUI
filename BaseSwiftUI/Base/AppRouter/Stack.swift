//
//  Stack.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

public extension AppRouter {
    struct Stack<Root>: View where Root : View {
        @Environment(\.dismiss)
        var dismiss

        @ViewBuilder
        public var root: Root
        
        public init(
            @ViewBuilder root: () -> Root
        ) {
            self.root = root()
        }
        
        public var body: some View {
            AppRouter.DismissableStackWrapper(
                dismiss: self.dismiss
            ) {
                self.root
            }
        }
    }
}
