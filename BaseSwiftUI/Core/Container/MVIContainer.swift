//
//  MVIContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 6/4/26.
//

import SwiftUI
import Combine

@MainActor
public protocol MVIContainer: ObservableObject {
    associatedtype F: MVIFeature
    
    var state: F.State { get }
    var effects: AnyPublisher<F.Effect, Never> { get }
    @discardableResult
    func send(_ intent: F.Intent) -> Task<Void, Never>
}
