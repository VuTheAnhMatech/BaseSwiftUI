//
//  BaseTextField.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 14/7/26.
//

import SwiftUI

struct BaseTextField: View {
    @Binding var text: String

    let placeholder: String
    let font: AppFont
    let textColor: Color
    let placeholderColor: Color
    let tintColor: Color?
    let size: CGFloat
    let horizontalPadding: CGFloat
    let height: CGFloat?
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let submitLabel: SubmitLabel
    let textInputAutocapitalization: TextInputAutocapitalization?
    let isAutocorrectionDisabled: Bool
    let focused: FocusState<Bool>.Binding?
    let onSubmit: () -> Void

    init(
        text: Binding<String>,
        placeholder: String = "",
        font: AppFont,
        textColor: Color = .primary,
        placeholderColor: Color = .secondary,
        tintColor: Color? = nil,
        size: CGFloat,
        horizontalPadding: CGFloat = 0,
        height: CGFloat? = nil,
        backgroundColor: Color = .clear,
        cornerRadius: CGFloat = 0,
        submitLabel: SubmitLabel = .done,
        textInputAutocapitalization: TextInputAutocapitalization? = nil,
        isAutocorrectionDisabled: Bool = false,
        focused: FocusState<Bool>.Binding? = nil,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.font = font
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.tintColor = tintColor
        self.size = size
        self.horizontalPadding = horizontalPadding
        self.height = height
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.submitLabel = submitLabel
        self.textInputAutocapitalization = textInputAutocapitalization
        self.isAutocorrectionDisabled = isAutocorrectionDisabled
        self.focused = focused
        self.onSubmit = onSubmit
    }

    var body: some View {
        ZStack(alignment: .leading) {
            focusedTextField
                .padding(.horizontal, horizontalPadding)
                .frame(height: height)

            if isPlaceholderVisible {
                BaseText(
                    placeholder,
                    font: font,
                    textColor: placeholderColor,
                    size: size,
                    lineSpacing: 0
                )
                .lineLimit(1)
                .padding(.horizontal, horizontalPadding)
                .allowsHitTesting(false)
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor)
        )
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

private extension BaseTextField {
    var isPlaceholderVisible: Bool {
        placeholder.isEmpty == false &&
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    var focusedTextField: some View {
        if let focused {
            configuredTextField
                .focused(focused)
        } else {
            configuredTextField
        }
    }

    var configuredTextField: some View {
        TextField("", text: $text)
            .font(.custom(font.rawValue, size: size))
            .foregroundStyle(textColor)
            .tint(tintColor ?? textColor)
            .submitLabel(submitLabel)
            .textInputAutocapitalization(textInputAutocapitalization)
            .autocorrectionDisabled(isAutocorrectionDisabled)
            .onSubmit(onSubmit)
    }
}
