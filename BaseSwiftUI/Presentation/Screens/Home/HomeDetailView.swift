// Created by Vu The Anh

import SwiftUI

struct HomeDetailView: View {
    let item: HomeItem
    @Environment(\.router) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            BaseTextButton(title: "Back") { router.goBack() }
                .frame(minWidth: 44, minHeight: 44)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    BaseText(item.title, font: .plusJakartaSansBold, size: 26)
                        .accessibilityAddTraits(.isHeader)
                    BaseText(item.body, font: .plusJakartaSansRegular, size: 17)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
    }
}
