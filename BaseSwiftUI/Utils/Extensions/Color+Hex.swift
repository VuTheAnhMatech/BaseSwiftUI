//
//  Color+Hex.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else {
            return nil
        }

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            a = 255
            r = ((value >> 8) & 0xF) * 17
            g = ((value >> 4) & 0xF) * 17
            b = (value & 0xF) * 17
        case 6:
            a = 255
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        case 8:
            a = (value >> 24) & 0xFF
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        default:
            return nil
        }

        self = Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview("Hex #FFFFFF") {
    VStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "#FFFFFF") ?? .clear)
            .frame(width: 140, height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

        Text("Color(hex: \"#FFFFFF\")")
            .font(.caption)
            .foregroundStyle(.white)
    }
    .padding(20)
    .background(Color.black)
}
