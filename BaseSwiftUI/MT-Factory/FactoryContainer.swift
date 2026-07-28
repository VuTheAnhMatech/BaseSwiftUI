//
//  FactoryContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Factory

extension Container {
    var homeContainer: Factory<HomeContainer> {
        self { HomeContainer() }
    }
}
