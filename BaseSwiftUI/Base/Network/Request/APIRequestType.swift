//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation
import Alamofire
import Combine

protocol APIRequestType {
    associatedtype Response: Decodable

    var path: String { get }
    var method: HTTPMethod { get }

    var headers: [String: String] { get }
    var queryParameters: Parameters? { get }
    var body: (any Encodable)? { get }

    var parameterEncoding: ParameterEncoding { get }
    var requiresAuthorization: Bool { get }
    var acceptableStatusCodes: Range<Int> { get }
    var timeoutInterval: TimeInterval? { get }
    var decoder: JSONDecoder { get }
}

extension APIRequestType {
    var headers: [String: String] { [:] }
    var queryParameters: Parameters? { nil }
    var body: (any Encodable)? { nil }
    var requiresAuthorization: Bool { true }
    var acceptableStatusCodes: Range<Int> { 200..<300 }
    var timeoutInterval: TimeInterval? { nil }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }

    var parameterEncoding: ParameterEncoding {
        switch method {
        case .get, .delete:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}
