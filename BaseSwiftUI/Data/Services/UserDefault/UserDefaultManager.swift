//
//  UserDefaultManager.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/7/26.
//

import Foundation

final class UserDefaultManager {
    static let shared = UserDefaultManager()

    private enum Keys {
        static let hasCompletedOnboarding = "app.hasCompletedOnboarding"
        static let preferredAppearance = "app.preferredAppearance"
    }

    @KeyValueBinding(key: Keys.hasCompletedOnboarding, defaultValue: false)
    var hasCompletedOnboarding: Bool

    @KeyValueBinding(key: Keys.preferredAppearance, defaultValue: "system")
    var preferredAppearance: String

    private init() {}
}
