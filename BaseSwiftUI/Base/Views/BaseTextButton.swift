//
//  BaseTextButton.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 20/5/26.
//

import SwiftUI

enum BaseTextButtonStyle {
    case plain
    case liquidAdaptive
}

struct BaseTextButton: View {
    let title: String
    let font: AppFont
    let textColor: Color
    let size: CGFloat
    let style: BaseTextButtonStyle
    let height: CGFloat
    let horizontalPadding: CGFloat
    let onSelect: () -> Void

    init(
        title: String,
        font: AppFont = .plusJakartaSansSemiBold,
        textColor: Color = .primary,
        size: CGFloat = 16,
        style: BaseTextButtonStyle = .plain,
        height: CGFloat = 34,
        horizontalPadding: CGFloat = 14,
        onSelect: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.textColor = textColor
        self.size = size
        self.style = style
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.onSelect = onSelect
    }

    var body: some View {
        switch style {
        case .plain:
            plainButton
        case .liquidAdaptive:
            liquidAdaptiveButton
        }
    }

    private var plainButton: some View {
        Button(action: onSelect) {
            BaseText(title, font: font, textColor: textColor, size: size)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var liquidAdaptiveButton: some View {
        if Constant.isEnableLiquidGlass {
            if #available(iOS 26, *) {
                Button(action: onSelect) {
                    BaseText(title, font: font, textColor: textColor, size: size)
                        .padding(.horizontal, horizontalPadding)
                        .frame(height: height)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
            } else {
                plainButton
            }
        } else {
            plainButton
        }
    }
}
