// Created by Vu The Anh

// Presentation snapshot carried by the typed route; no transport DTO reaches UI.
struct HomeItem: Identifiable, Hashable, Codable {
    let id: Int
    let title: String
    let body: String

    init(post: HomePost) {
        id = post.id
        title = post.title
        body = post.body
    }
}
