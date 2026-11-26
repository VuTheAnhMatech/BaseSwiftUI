// Created by Vu The Anh

import Foundation

struct RemoteHomePostRepository: HomePostRepository {
    let service: any HomePostService

    func fetchPosts() async throws -> [HomePost] {
        let response = try await service.fetchPosts()
        try Task.checkCancellation()
        return response.map { $0.toDomain() }
    }
}
