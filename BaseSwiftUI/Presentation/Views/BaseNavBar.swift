//
//  BaseNavBar.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 15/4/26.
//

import SwiftUI

struct BaseNavBar: View {
    let title: String
    let leadingImage: Image
    let trailingImage: Image?
    let trailingOpacity: CGFloat
    let onTapLeading: () -> Void
    let onTapTrailing: (() -> Void)?

    init(
        title: String,
        leadingImage: Image,
        trailingImage: Image? = nil,
        trailingOpacity: CGFloat = 1,
        onTapLeading: @escaping () -> Void,
        onTapTrailing: (() -> Void)? = nil
    ) {
        self.title = title
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.trailingOpacity = trailingOpacity
        self.onTapLeading = onTapLeading
        self.onTapTrailing = onTapTrailing
    }

    var body: some View {
        HStack {
            BaseButton(
                image: leadingImage,
                width: 24,
                height: 24,
                style: .liquidAdaptive,
                liquidFrameSize: 40,
                liquidIconSize: 20,
                onSelect: onTapLeading
            )

            Spacer()

            BaseText(title, font: .plusJakartaSansSemiBold, textColor: Color.white, size: 17)

            Spacer()

            if let trailingImage {
                BaseButton(
                    image: trailingImage,
                    width: 24,
                    height: 24,
                    style: .liquidAdaptive,
                    liquidFrameSize: 40,
                    liquidIconSize: 20,
                    onSelect: {
                    onTapTrailing?()
                })
                .opacity(trailingOpacity)
            } else {
                Color.clear
                    .frame(width: navButtonFrameSize, height: navButtonFrameSize)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }

    private var navButtonFrameSize: CGFloat {
        if Constant.isEnableLiquidGlass {
            return 40
        }
        return 24
    }

}
