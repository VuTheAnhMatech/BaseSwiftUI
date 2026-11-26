// Created by Vu The Anh

import Foundation

protocol LoadHomePostsUseCase {
    func execute() async throws -> [HomePost]
}

struct LoadHomePosts: LoadHomePostsUseCase {
    let repository: any HomePostRepository

    func execute() async throws -> [HomePost] {
        let posts = try await repository.fetchPosts()
        try Task.checkCancellation()
        // Show each valid post once, preserving server order.
        var seenIDs = Set<Int>()
        return posts.filter {
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && seenIDs.insert($0.id).inserted
        }
    }
}
