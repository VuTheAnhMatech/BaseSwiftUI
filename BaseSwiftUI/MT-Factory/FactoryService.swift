//
//  FactoryService.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Factory

extension Container {
    var userDefaultManager: Factory<UserDefaultManager> {
        self { UserDefaultManager.shared }.singleton
    }
}
