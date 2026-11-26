//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noInternet
    case timeout
    case unauthorized
    case forbidden
    case cancelled
    case server(statusCode: Int, data: Data?)
    case business(code: Int?, message: String?)
    case decoding(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noInternet:
            return "No internet connection."
        case .timeout:
            return "The request timed out."
        case .unauthorized:
            return "Unauthorized."
        case .forbidden:
            return "Forbidden."
        case .cancelled:
            return "The request was cancelled."
        case .server(let statusCode, _):
            return "Server error (status code: \(statusCode))."
        case .business(_, let message):
            return message ?? "Business validation failed."
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
