// Created by Vu The Anh

import Factory

extension Container {
    var loadHomePosts: Factory<any LoadHomePostsUseCase> {
        self { LoadHomePosts(repository: self.homePostRepository()) }
    }
}
