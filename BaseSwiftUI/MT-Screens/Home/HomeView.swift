//
//  HomeView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var container: HomeContainer

    var body: some View {
        Text(container.state.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        .injectRouter(to: container)
    }
}

struct SampleDetailView: View {
    @EnvironmentObject private var router: RouterController.StackController

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            BaseText("Typed routing works", font: .plusJakartaSansBold, size: 24)
            BaseTextButton(title: "Go back", style: .liquidAdaptive) {
                router.goBack()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}
