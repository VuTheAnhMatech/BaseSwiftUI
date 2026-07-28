//
//  BaseContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 6/4/26.
//

import Combine
import Factory

open class BaseContainer<F: MVIFeature>: MVIContainer {
    @Published public var state: F.State
    @Published public var isLoading = false
    var cancellables = Set<AnyCancellable>()

    deinit {
        print("🗑️ Container Destroyed: \(self) \(ObjectIdentifier(self))")
    }
    
    public init() {
        self.state = F.State()
    }
    
    public func send(_ intent: F.Intent) {
        handleIntent(intent)
    }
    
    open func handleIntent(_ intent: F.Intent) {
        fatalError("")
    }
    
    @inlinable
    public final func runLoadingTask(_ work: @escaping () async -> Void) {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            defer { self?.isLoading = false }
            await work()
        }
    }

}
