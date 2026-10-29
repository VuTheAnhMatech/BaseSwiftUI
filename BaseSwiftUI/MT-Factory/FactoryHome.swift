// Created by Vu The Anh

import Factory

extension Container {
    var homeAPIService: Factory<any APIServiceProtocol> {
        self {
            APIService(
                environment: .custom("https://jsonplaceholder.typicode.com"),
                tokenStore: TokenStore.shared,
                refresher: nil,
                eventMonitors: []
            )
        }.singleton
    }

    var homePostRepository: Factory<any HomePostRepository> {
        self { RemoteHomePostRepository(apiService: self.homeAPIService()) }
    }

    var loadHomePosts: Factory<any LoadHomePostsUseCase> {
        self { LoadHomePosts(repository: self.homePostRepository()) }
    }
}
