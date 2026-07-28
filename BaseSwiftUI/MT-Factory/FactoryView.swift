//
//  FactoryView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Factory
import SwiftUI

extension Container {
    @MainActor
    func homeView() -> some View {
        HomeView(container: self.homeContainer())
    }
}
