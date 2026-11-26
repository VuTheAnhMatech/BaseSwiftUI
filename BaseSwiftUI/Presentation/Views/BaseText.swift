//
//  BaseText.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 15/4/26.
//

import SwiftUI

enum AppFont: String {
    case dmSerifTextRegular = "DMSerifText-Regular"

    case interThin = "Inter-Thin"
    case interExtraLight = "Inter-ExtraLight"
    case interLight = "Inter-Light"
    case interRegular = "Inter-Regular"
    case interMedium = "Inter-Medium"
    case interSemiBold = "Inter-SemiBold"
    case interBold = "Inter-Bold"
    case interExtraBold = "Inter-ExtraBold"
    case interBlack = "Inter-Black"

    case plusJakartaSansExtraLight = "PlusJakartaSans-Regular_ExtraLight"
    case plusJakartaSansLight = "PlusJakartaSans-Regular_Light"
    case plusJakartaSansRegular = "PlusJakartaSans-Regular"
    case plusJakartaSansMedium = "PlusJakartaSans-Regular_Medium"
    case plusJakartaSansSemiBold = "PlusJakartaSans-Regular_SemiBold"
    case plusJakartaSansBold = "PlusJakartaSans-Regular_Bold"
    case plusJakartaSansExtraBold = "PlusJakartaSans-Regular_ExtraBold"
    case plusJakartaSansItalic = "PlusJakartaSans-Italic"
}

struct BaseText: View {
    let text: String
    let font: AppFont
    let textColor: Color
    let size: CGFloat
    let lineSpacing: CGFloat

    init(
        _ text: String,
        font: AppFont,
        textColor: Color = .primary,
        size: CGFloat,
        lineSpacing: CGFloat = 4
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.size = size
        self.lineSpacing = lineSpacing
    }

    var body: some View {
        Text(text)
            .lineLimit(nil)
            .font(.custom(font.rawValue, size: size))
            .foregroundColor(textColor)
            .lineSpacing(lineSpacing)
    }
}

struct BaseHightLightTextAttribute {
    let font: AppFont
    let textColor: Color
    let size: CGFloat
    let isStrikethrough: Bool

    init(font: AppFont, textColor: Color, size: CGFloat, isStrikethrough: Bool = false) {
        self.font = font
        self.textColor = textColor
        self.size = size
        self.isStrikethrough = isStrikethrough
    }
}

struct BaseHightLightText: View {
    let fullText: String
    let hightlightTexts: [String]
    let attributes: [BaseHightLightTextAttribute]
    let font: AppFont
    let textColor: Color
    let size: CGFloat
    let lineSpacing: CGFloat

    init(
        _ fullText: String,
        hightlightTexts: [String],
        attributes: [BaseHightLightTextAttribute],
        font: AppFont,
        textColor: Color = .primary,
        size: CGFloat,
        lineSpacing: CGFloat = 4
    ) {
        self.fullText = fullText
        self.hightlightTexts = hightlightTexts
        self.attributes = attributes
        self.font = font
        self.textColor = textColor
        self.size = size
        self.lineSpacing = lineSpacing
    }

    var body: some View {
        Text(styledText)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(lineSpacing)
    }

    private var styledText: AttributedString {
        var attributed = AttributedString(fullText)
        attributed.font = .custom(font.rawValue, size: size)
        attributed.foregroundColor = textColor

        for (index, hightlightText) in hightlightTexts.enumerated() {
            guard !hightlightText.isEmpty else { continue }
            let attribute = attributes.indices.contains(index) ? attributes[index] : attributes.last
            guard let attribute else { continue }

            var searchStart = attributed.startIndex
            while searchStart < attributed.endIndex,
                  let foundRange = attributed[searchStart...].range(of: hightlightText) {
                attributed[foundRange].font = .custom(attribute.font.rawValue, size: attribute.size)
                attributed[foundRange].foregroundColor = attribute.textColor
                attributed[foundRange].strikethroughStyle = attribute.isStrikethrough ? .single : nil
                searchStart = foundRange.upperBound
            }
        }

        return attributed
    }
}
