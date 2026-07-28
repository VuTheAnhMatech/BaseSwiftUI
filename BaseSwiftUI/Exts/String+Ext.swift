//
//  String+Exts.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 22/4/26.
//

import Foundation

extension String {
    static func formattedRemainingTime(elapsed: TimeInterval, duration: TimeInterval) -> String {
        let remaining = Swift.max(0, duration - elapsed)
        let totalSeconds = Int(remaining)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
}
