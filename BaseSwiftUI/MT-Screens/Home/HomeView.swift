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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    BaseText(container.state.title, font: .plusJakartaSansBold, textColor: .primary, size: 32)
                    BaseText("A reusable SwiftUI starter extracted from proven app architecture.", font: .plusJakartaSansRegular, textColor: .secondary, size: 16)
                }

                BaseStackView(dataSource: container.dataSource, spacing: 12) { item in
                    HStack(spacing: 16) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            BaseText(item.title, font: .plusJakartaSansSemiBold, size: 17)
                            BaseText(item.subtitle, font: .plusJakartaSansRegular, textColor: .secondary, size: 14)
                        }

                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("")
        .task { container.send(.load) }
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
