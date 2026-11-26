// Created by Vu The Anh

import Factory

extension Container {
    var tokenStore: Factory<any TokenStoreProtocol> {
        self { TokenStore.shared }.cached
    }

    var homeAPIService: Factory<any APIServiceProtocol> {
        self {
            APIService(environment: .custom("https://jsonplaceholder.typicode.com"),
                       tokenStore: self.tokenStore(), refresher: nil, eventMonitors: [])
        }.cached
    }
    var homePostService: Factory<any HomePostService> {
        self { RemoteHomePostService(apiService: self.homeAPIService()) }.cached
    }
    var userDefaultManager: Factory<UserDefaultManager> {
        self { UserDefaultManager.shared }.cached
    }
}
