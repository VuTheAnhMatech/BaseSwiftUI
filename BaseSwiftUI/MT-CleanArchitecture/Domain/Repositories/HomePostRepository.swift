// Created by Vu The Anh

protocol HomePostRepository {
    func fetchPosts() async throws -> [HomePost]
}
