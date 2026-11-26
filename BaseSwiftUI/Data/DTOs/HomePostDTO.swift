// Created by Vu The Anh

struct HomePostDTO: Decodable {
    let id: Int
    let title: String
    let body: String

    func toDomain() -> HomePost {
        HomePost(id: id, title: title, body: body)
    }
}
