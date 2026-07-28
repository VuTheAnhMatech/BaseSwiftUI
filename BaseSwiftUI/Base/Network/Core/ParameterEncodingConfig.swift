//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation
import Alamofire

struct BracketLessGetEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding.default.encode(urlRequest, with: parameters)
        request.url = URL(
            string: request.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "=") ?? ""
        )
        return request
    }
}

struct BracketLessPostEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding.httpBody.encode(urlRequest, with: parameters)
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            request.httpBody = bodyString
                .replacingOccurrences(of: "%5B%5D=", with: "=")
                .data(using: .utf8)
        }
        return request
    }
}
