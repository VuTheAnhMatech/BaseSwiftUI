//
//  ObservedStack.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

public extension AppRouter {
    struct ObservedStack<Root> : View where Root : View {
        @ObservedObject var stack: AppRouter.StackController
        
        @ViewBuilder
        var root: Root
        
        public var body: some View {
            NavigationStack(
                path: self.$stack.path
            ) {
                self.root
                    .navigationDestination(
                        for: Route.self
                    ) {
                        $0.content
                            .frame(maxHeight: .infinity)
                            .navigationTitle("")
                            .navigationBarBackButtonHidden(true)
                    }
                    .frame(maxHeight: .infinity)
                    .navigationTitle("")
                    .navigationBarBackButtonHidden(true)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .accentColor(Color.primary)
            .environmentObject(self.stack)
            .overlay {
                if let fadeCoverRoute = stack.fadeCoverRoute {
                    fadeCoverRoute.content
                        .environmentObject(stack)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .sheet(
                item: self.$stack.sheetRoute,
                onDismiss: {
                    stack.handleSheetDismiss()
                }
            ) { sheetRoute in
                AppRouter.Stack {
                    sheetRoute.route.content
                }
                .environment(\.sheetPresentationUpdater) { presentation in
                    stack.updateSheetPresentation(presentation)
                }
                .presentationDetents(sheetRoute.presentation, selection: $stack.selectedSheetPresentation)
                .presentationDragIndicator(sheetRoute.dragIndicator.swiftUIVisibility)
            }
#if os(iOS)
            .fullScreenCover(
                item: self.$stack.fullScreenCoverRoute
            ) { coverRoute in
                AppRouter.Stack {
                    coverRoute.content
                }
                .presentationBackground(.clear)
            }
#endif
        }
    }
}
