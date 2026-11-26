//
//  KeyValueBinding.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 20/4/26.
//

import Foundation

@propertyWrapper
struct KeyValueBinding<Value> {
    private let key: String
    private let defaultValue: Value
    private let userDefaults: UserDefaults

    init(key: String, defaultValue: Value, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: Value {
        get {
            userDefaults.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}
