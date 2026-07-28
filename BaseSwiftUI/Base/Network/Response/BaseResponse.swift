//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

struct BaseResponse: Decodable {
    let code: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case code
        case message = "msg"
    }

    var isSuccess: Bool {
        code == 200 || code == nil
    }
}

struct BaseSingleResponse<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: T?
    let resultImage: String?

    enum CodingKeys: String, CodingKey {
        case code
        case message = "msg"
        case data
        case resultImage = "result_image"
    }

    var isSuccess: Bool {
        code == 200 || code == nil
    }
}
