//
//  HomeContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Combine
import Foundation

enum HomeFeature: MVIFeature {
    struct State: DefaultInitializable {
        var title = "Sample posts"
        var hasLoaded = false
        var isEmpty = false
        var errorMessage: String?
    }

    enum Intent {
        case load
        case retry
        case disappear
        case select(HomeItem)
    }
}

final class HomeContainer: BaseRouteContainer<HomeFeature, AppNavigationRoute> {
    let dataSource = BaseDataSource<HomeItem>()
    private let loadPosts: any LoadHomePostsUseCase

    init(loadPosts: any LoadHomePostsUseCase) {
        self.loadPosts = loadPosts
        super.init()
        bindDataSource()
    }

    override func handleIntent(_ intent: HomeFeature.Intent) {
        switch intent {
        case .load:
            guard !state.hasLoaded, state.errorMessage == nil else { return }
            load()
        case .retry:
            load()
        case .disappear:
            cancelTask(id: "home.load")
        case .select(let item):
            router?.push(route: .detail(item))
        }
    }

    private func load() {
        guard !isLoading else { return }
        updateState { $0.errorMessage = nil }
        let useCase = loadPosts
        runTask(id: "home.load") { [weak self] in
            do {
                let posts = try await useCase.execute()
                try Task.checkCancellation()
                let items = posts.map(HomeItem.init(post:))
                self?.dataSource.setListItem(items)
                self?.updateState {
                    $0.hasLoaded = true
                    $0.isEmpty = items.isEmpty
                }
            } catch {
                guard !Task.isCancelled else { return }
                self?.updateState {
                    $0.errorMessage = "Couldn't load posts. Check your connection and try again."
                }
            }
        }
    }

    private func bindDataSource() {
        dataSource.selectedValue
            .sink { [weak self] item in
                self?.send(.select(item))
            }
            .store(in: &cancellables)
    }
}
