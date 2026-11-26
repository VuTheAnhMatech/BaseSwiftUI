//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

enum APIEnvironment {
    case dev
    case staging
    case production
    case custom(String)

    var baseURL: String {
        switch self {
        case .dev:
            return ""
        case .staging:
            return ""
        case .production:
            return ""
        case .custom(let url):
            return url
        }
    }
}
