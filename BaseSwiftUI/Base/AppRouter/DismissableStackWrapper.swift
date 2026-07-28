//
//  DismissableStackWrapper.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

public extension AppRouter {
    struct DismissableStackWrapper<Root>: View where Root : View {
        @StateObject
        var stackController: StackController
        
        @ViewBuilder
        public var root: Root
        
        public init(
            dismiss: DismissAction,
            @ViewBuilder root: () -> Root
        ) {
            self._stackController = StateObject(
                wrappedValue: .init(dismiss: dismiss)
            )
            
            self.root = root()
        }
        
        public var body: some View {
            AppRouter.ObservedStack(
                stack: self.stackController
            ) {
                self.root
            }
        }
    }
}
