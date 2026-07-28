//
//  HomeContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import Combine

enum HomeFeature: MVIFeature {
    struct State: DefaultInitializable {
        var title = "BaseSwiftUI"
    }

    enum Intent {
        case load
        case select(HomeItem)
    }
}

final class HomeContainer: BaseRouteContainer<HomeFeature, AppNavigationRoute> {
    let dataSource = BaseDataSource<HomeItem>()

    override init() {
        super.init()
        bindDataSource()
    }

    override func handleIntent(_ intent: HomeFeature.Intent) {
        switch intent {
        case .load:
            dataSource.setListItem(HomeItem.defaults)
        case .select:
            router?.push(route: .detail)
        }
    }

    private func bindDataSource() {
        dataSource.tappedItemSubject
            .compactMap(\.0)
            .sink { [weak self] item in
                self?.send(.select(item))
            }
            .store(in: &cancellables)
    }
}
