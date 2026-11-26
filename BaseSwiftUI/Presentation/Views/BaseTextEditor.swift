//
//  BaseTextEditor.swift
//  BaseSwiftUI
//

import SwiftUI

struct BaseTextEditor: View {
    @Binding var text: String

    let placeholder: String
    let font: AppFont
    let textColor: Color
    let placeholderColor: Color
    let size: CGFloat
    let lineSpacing: CGFloat
    let textInsets: EdgeInsets
    let placeholderInsets: EdgeInsets
    let placeholderMinimumScaleFactor: CGFloat

    init(
        text: Binding<String>,
        placeholder: String = "",
        font: AppFont,
        textColor: Color = .primary,
        placeholderColor: Color = .secondary,
        size: CGFloat,
        lineSpacing: CGFloat = 0,
        textInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        placeholderInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        placeholderMinimumScaleFactor: CGFloat = 0.8
    ) {
        self._text = text
        self.placeholder = placeholder
        self.font = font
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.size = size
        self.lineSpacing = lineSpacing
        self.textInsets = textInsets
        self.placeholderInsets = placeholderInsets
        self.placeholderMinimumScaleFactor = placeholderMinimumScaleFactor
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.custom(font.rawValue, size: size))
                .foregroundColor(textColor)
                .lineSpacing(lineSpacing)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(textInsets)

            if !placeholder.isEmpty {
                BaseText(
                    placeholder,
                    font: font,
                    textColor: placeholderColor,
                    size: size,
                    lineSpacing: lineSpacing
                )
                .lineLimit(1)
                .minimumScaleFactor(placeholderMinimumScaleFactor)
                .padding(placeholderInsets)
                .opacity(text.isEmpty ? 1 : 0)
                .allowsHitTesting(false)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}
