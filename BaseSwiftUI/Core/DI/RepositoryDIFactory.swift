// Created by Vu The Anh

import Factory

extension Container {
    var homePostRepository: Factory<any HomePostRepository> {
        self { RemoteHomePostRepository(service: self.homePostService()) }.cached
    }
}
