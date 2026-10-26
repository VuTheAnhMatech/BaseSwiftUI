//
//  BaseContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 6/4/26.
//

import Combine
import Foundation

@MainActor
open class BaseContainer<F: MVIFeature>: MVIContainer {
    @Published public private(set) var state: F.State
    @Published public private(set) var isLoading = false
    var cancellables = Set<AnyCancellable>()
    private var tasks: [AnyHashable: (token: UUID, task: Task<Void, Never>, showsLoading: Bool)] = [:]

    deinit {
        tasks.values.forEach { $0.task.cancel() }
    }
    
    public init() {
        self.state = F.State()
    }
    
    public final func send(_ intent: F.Intent) {
        handleIntent(intent)
    }
    
    open func handleIntent(_ intent: F.Intent) {
        preconditionFailure("Subclasses must override handleIntent(_:)")
    }

    public final func updateState(_ mutation: (inout F.State) -> Void) {
        mutation(&state)
    }

    /// Independent loading work. Use runTask(id:) when new work replaces an earlier request.
    @discardableResult
    public final func runLoadingTask(
        _ work: @escaping @MainActor () async -> Void
    ) -> Task<Void, Never> {
        runTask(id: UUID(), work)
    }

    /// Work must cooperate with cancellation and check it before publishing results.
    /// Capture the container weakly in work; the task manager does not retain it across await.
    @discardableResult
    public final func runTask(
        id: AnyHashable,
        showsLoading: Bool = true,
        _ work: @escaping @MainActor () async -> Void
    ) -> Task<Void, Never> {
        tasks[id]?.task.cancel()
        let token = UUID()
        let task = Task { @MainActor [weak self] in
            if !Task.isCancelled {
                await work()
            }
            self?.finishTask(id: id, token: token)
        }
        tasks[id] = (token, task, showsLoading)
        updateLoadingState()
        return task
    }

    public final func cancelTask(id: AnyHashable) {
        tasks.removeValue(forKey: id)?.task.cancel()
        updateLoadingState()
    }

    public final func cancelAllTasks() {
        tasks.values.forEach { $0.task.cancel() }
        tasks.removeAll()
        updateLoadingState()
    }

    private func finishTask(id: AnyHashable, token: UUID) {
        guard tasks[id]?.token == token else { return }
        tasks.removeValue(forKey: id)
        updateLoadingState()
    }

    private func updateLoadingState() {
        let isLoading = tasks.values.contains { $0.showsLoading }
        guard self.isLoading != isLoading else { return }
        self.isLoading = isLoading
    }

}
