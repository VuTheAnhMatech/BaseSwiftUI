// Created by Vu The Anh

import Alamofire
import Foundation

protocol HomePostService {
    func fetchPosts() async throws -> [HomePostDTO]
}

private struct HomePostsRequest: APIRequestType {
    typealias Response = HomePostDTO
    var path: String { "/posts" }
    var method: HTTPMethod { .get }
    var requiresAuthorization: Bool { false }
    var timeoutInterval: TimeInterval? { 20 }
}

struct RemoteHomePostService: HomePostService {
    let apiService: any APIServiceProtocol

    func fetchPosts() async throws -> [HomePostDTO] {
        try await apiService.requestArray(HomePostsRequest())
    }
}
