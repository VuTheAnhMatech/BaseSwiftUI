//
//  Error+Ext.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 1/6/26.
//

import Foundation
internal import StoreKit

extension Error {
    var isNoInternetError: Bool {
        if let networkError = self as? NetworkError {
            return networkError.isNoInternetError
        }

        if let urlError = self as? URLError {
            return urlError.isNoInternetError
        }

        if let storeKitError = self as? StoreKitError {
            return storeKitError.isNoInternetError
        }

        let nsError = self as NSError
        return nsError.isNoInternetNSError || nsError.underlyingError?.isNoInternetError == true
    }

}

private enum NoInternetErrorMatcher {
    static let urlCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .cannotFindHost,
        .cannotConnectToHost,
        .timedOut,
        .dataNotAllowed,
        .internationalRoamingOff
    ]
}

private extension NetworkError {
    var isNoInternetError: Bool {
        switch self {
        case .noInternet:
            return true
        case .underlying(let error):
            return error.isNoInternetError
        default:
            return false
        }
    }
}

private extension URLError {
    var isNoInternetError: Bool {
        NoInternetErrorMatcher.urlCodes.contains(code)
    }
}

private extension StoreKitError {
    var isNoInternetError: Bool {
        switch self {
        case .networkError(let urlError):
            return urlError.isNoInternetError
        default:
            return false
        }
    }
}

private extension NSError {
    var isNoInternetNSError: Bool {
        guard domain == NSURLErrorDomain else { return false }
        return NoInternetErrorMatcher.urlCodes.contains(URLError.Code(rawValue: code))
    }

    var underlyingError: Error? {
        userInfo[NSUnderlyingErrorKey] as? Error
    }
}
