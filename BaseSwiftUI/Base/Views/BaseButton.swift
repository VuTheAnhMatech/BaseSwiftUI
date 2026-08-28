//
//  BaseButton.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 15/4/26.
//

import SwiftUI

enum BaseButtonStyle {
    case plain
    case liquidAdaptive
    case liquidStatic
}

enum BaseButtonLiquidShape {
    case circle
    case capsule
}

private struct GlassShapeButton: ButtonStyle {
    let shape: BaseButtonLiquidShape
    let isInteractive: Bool

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26, *) {
            switch shape {
            case .circle:
                configuration.label
                    .fixedSize()
                    .contentShape(.circle)
                    .glassEffect(isInteractive ? .regular.interactive() : .regular, in: .circle)
            case .capsule:
                configuration.label
                    .fixedSize()
                    .contentShape(.capsule)
                    .glassEffect(isInteractive ? .regular.interactive() : .regular, in: .capsule)
            }
        } else {
            configuration.label
        }
    }
}

private extension ButtonStyle where Self == GlassShapeButton {
    static func glassShape(_ shape: BaseButtonLiquidShape, isInteractive: Bool) -> Self {
        Self(shape: shape, isInteractive: isInteractive)
    }
}

struct BaseButton: View {
    let image: Image?
    let customLabel: AnyView?
    let width: CGFloat
    let height: CGFloat
    let style: BaseButtonStyle
    let liquidFrameSize: CGFloat
    let liquidIconSize: CGFloat
    let liquidShape: BaseButtonLiquidShape
    let appliesLiquidFrame: Bool
    let onSelect: () -> Void

    init(
        image: Image? = nil,
        width: CGFloat = 24,
        height: CGFloat = 24,
        style: BaseButtonStyle = .liquidAdaptive,
        liquidFrameSize: CGFloat = 44,
        liquidIconSize: CGFloat = 24,
        liquidShape: BaseButtonLiquidShape = .circle,
        appliesLiquidFrame: Bool = true,
        onSelect: @escaping () -> Void
    ) {
        self.image = image
        self.customLabel = nil
        self.width = width
        self.height = height
        self.style = style
        self.liquidFrameSize = liquidFrameSize
        self.liquidIconSize = liquidIconSize
        self.liquidShape = liquidShape
        self.appliesLiquidFrame = appliesLiquidFrame
        self.onSelect = onSelect
    }

    init<Label: View>(
        width: CGFloat = 24,
        height: CGFloat = 24,
        style: BaseButtonStyle = .liquidAdaptive,
        liquidFrameSize: CGFloat = 44,
        liquidIconSize: CGFloat = 24,
        liquidShape: BaseButtonLiquidShape = .circle,
        appliesLiquidFrame: Bool = true,
        onSelect: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.image = nil
        self.customLabel = AnyView(label())
        self.width = width
        self.height = height
        self.style = style
        self.liquidFrameSize = liquidFrameSize
        self.liquidIconSize = liquidIconSize
        self.liquidShape = liquidShape
        self.appliesLiquidFrame = appliesLiquidFrame
        self.onSelect = onSelect
    }

    var body: some View {
        switch style {
        case .plain:
            plainButton
        case .liquidAdaptive:
            liquidButton(isInteractive: true)
        case .liquidStatic:
            liquidButton(isInteractive: false)
        }
    }

    private var plainButton: some View {
        Button(action: onSelect) {
            buttonLabel(iconSize: CGSize(width: width, height: height), frameSize: nil)
                .frame(minWidth: 40, minHeight: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func liquidButton(isInteractive: Bool) -> some View {
        if #available(iOS 26, *), Constant.isEnableLiquidGlass {
            let frameSize = appliesLiquidFrame ? CGSize(width: liquidFrameSize, height: liquidFrameSize) : nil

            Button(action: onSelect) {
                buttonLabel(
                    iconSize: CGSize(width: liquidIconSize, height: liquidIconSize),
                    frameSize: frameSize
                )
            }
            .buttonStyle(.glassShape(liquidShape, isInteractive: isInteractive))
        } else if Constant.isEnableLiquidGlass {
            plainButton
                .background(.ultraThinMaterial, in: fallbackShape)
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
        } else {
            plainButton
        }
    }

    private var fallbackShape: AnyShape {
        switch liquidShape {
        case .circle:
            AnyShape(Circle())
        case .capsule:
            AnyShape(Capsule())
        }
    }

    @ViewBuilder
    private func buttonLabel(iconSize: CGSize, frameSize: CGSize?) -> some View {
        if let customLabel {
            customLabel
                .frame(width: frameSize?.width, height: frameSize?.height)
        } else if let image {
            image
                .resizable()
                .scaledToFit()
                .frame(width: iconSize.width, height: iconSize.height)
                .frame(width: frameSize?.width, height: frameSize?.height)
        } else {
            EmptyView()
        }
    }
}
