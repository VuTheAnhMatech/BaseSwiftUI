//
//  Views+Ext.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 15/4/26.
//

import SwiftUI
import UIKit

struct RoundedCornerShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension ShapeStyle where Self == LinearGradient {
    static var applyButtonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 102.0 / 255.0, blue: 0.0),
                Color(red: 1.0, green: 142.0 / 255.0, blue: 10.0 / 255.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension View {
    func applyBackgroundGradient() -> some View {
        background(
            Capsule(style: .continuous)
                .fill(.applyButtonGradient)
        )
    }
    
    func readHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }

    func readFrame(in coordinateSpace: CoordinateSpace, _ onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        onChange(proxy.frame(in: coordinateSpace))
                    }
                    .onChange(of: proxy.frame(in: coordinateSpace)) { _, frame in
                        onChange(frame)
                    }
            }
        )
    }

    func applyCardStroke(
        radius: CGFloat,
        colors: [Color] = [
            Color.white.opacity(0.2),
            Color.black.opacity(0.12)
        ]
    ) -> some View {
        let strokeColors = colors.isEmpty ? [
            Color.white.opacity(0.2),
            Color.black.opacity(0.12)
        ] : colors

        return overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: strokeColors,
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
    }

    func onBackgroundTap(_ action: @escaping () -> Void) -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                action()
            }
        )
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
