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
        VStack(alignment: .leading, spacing: 16) {
            BaseText(container.state.title, font: .plusJakartaSansBold, size: 28)
                .accessibilityAddTraits(.isHeader)
            BaseText("Sample content from JSONPlaceholder", font: .plusJakartaSansRegular,
                     textColor: .secondary, size: 14)
            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(uiColor: .systemBackground))
        .task { container.send(.load) }
        .onDisappear { container.send(.disappear) }
        .injectRouter(to: container)
    }

    @ViewBuilder
    private var content: some View {
        if container.isLoading {
            ProgressView("Loading posts…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = container.state.errorMessage {
            status(message, action: "Try again")
        } else if container.state.hasLoaded, container.state.isEmpty {
            status("No posts yet.", action: "Reload")
        } else if container.state.hasLoaded {
            BaseLazyListView(dataSource: container.dataSource, spacing: 12, showsIndicators: true) { item in
                VStack(alignment: .leading, spacing: 8) {
                    BaseText(item.title, font: .plusJakartaSansSemiBold, size: 18)
                    BaseText(item.body, font: .plusJakartaSansRegular, textColor: .secondary, size: 15)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Opens the full post")
                .accessibilityAction { container.send(.select(item)) }
            }
        }
    }

    private func status(_ message: String, action: String) -> some View {
        VStack(spacing: 20) {
            BaseText(message, font: .plusJakartaSansRegular, size: 17)
                .multilineTextAlignment(.center)
            BaseTextButton(title: action) { container.send(.retry) }
                .frame(minWidth: 44, minHeight: 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
