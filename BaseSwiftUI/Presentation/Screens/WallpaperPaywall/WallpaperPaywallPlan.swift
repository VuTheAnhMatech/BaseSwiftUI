// Created by Vu The Anh

import Foundation

/// Figma fixtures for the UI demo, never StoreKit product identifiers or live prices.
enum WallpaperPaywallPlan: String {
    case weekly
    case yearly

    var samplePrice: String { self == .weekly ? "$4.99" : "$29.99" }
    var samplePeriod: String { self == .weekly ? "1 Week" : "1 Year" }
}
