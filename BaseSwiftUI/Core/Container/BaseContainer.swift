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
    private var eventTail: Task<Void, Never>?
    private let effectSubject = PassthroughSubject<F.Effect, Never>()

    public var effects: AnyPublisher<F.Effect, Never> {
        effectSubject.eraseToAnyPublisher()
    }

    deinit {
        tasks.values.forEach { $0.task.cancel() }
    }
    
    public init() {
        self.state = F.State()
    }
    
    @discardableResult
    public final func send(_ intent: F.Intent) -> Task<Void, Never> {
        enqueue { [weak self] in await self?.dispatch(intent) }
    }

    @discardableResult
    public final func sendSystem(_ intent: SystemIntent) -> Task<Void, Never> {
        guard !Task.isCancelled else { return cancelledTask() }
        switch intent {
        case .onAppear, .onDisappear:
            // A new visibility session invalidates all pending events and owned work.
            cancelAllTasks()
        default:
            break
        }
        return enqueue { [weak self] in await self?.dispatchSystem(intent) }
    }

    private func enqueue(_ operation: @escaping @MainActor () async -> Void) -> Task<Void, Never> {
        guard !Task.isCancelled else { return cancelledTask() }
        let previous = eventTail
        let task = runTask(id: UUID(), showsLoading: false) {
            await previous?.value
            guard !Task.isCancelled else { return }
            await operation()
        }
        eventTail = task
        return task
    }

    private func cancelledTask() -> Task<Void, Never> {
        let task = Task<Void, Never> {}
        task.cancel()
        return task
    }

    open func dispatch(_ intent: F.Intent) async {
        preconditionFailure("Subclasses must override dispatch(_:)")
    }

    open func dispatchSystem(_ intent: SystemIntent) async {}

    public final func sendEffect(_ effect: F.Effect) {
        guard !Task.isCancelled else { return }
        effectSubject.send(effect)
    }

    public final func updateState(_ mutation: (inout F.State) -> Void) {
        guard !Task.isCancelled else { return }
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
        guard !Task.isCancelled else { return cancelledTask() }
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
        eventTail = nil
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
