// Created by Vu The Anh

import Foundation
import Alamofire

struct HomePostsRequest: APIRequestType {
    typealias Response = HomePostDTO

    var path: String { "/posts" }
    var method: HTTPMethod { .get }
    var requiresAuthorization: Bool { false }
    var timeoutInterval: TimeInterval? { 20 }
}

struct RemoteHomePostRepository: HomePostRepository {
    let apiService: any APIServiceProtocol

    func fetchPosts() async throws -> [HomePost] {
        let response = try await apiService.requestArray(HomePostsRequest())
        try Task.checkCancellation()
        return response.map { $0.toDomain() }
    }
}
