//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

protocol TokenStoreProtocol: AnyObject {
    var accessToken: String? { get }
    var refreshToken: String? { get }

    func save(accessToken: String?, refreshToken: String?)
    func clear()
}

final class TokenStore: TokenStoreProtocol {
    static let shared = TokenStore()

    private init() { }

    private enum Keys {
        static let accessToken = "network.accessToken"
        static let refreshToken = "network.refreshToken"
    }

    var accessToken: String? {
        UserDefaults.standard.string(forKey: Keys.accessToken)
    }

    var refreshToken: String? {
        UserDefaults.standard.string(forKey: Keys.refreshToken)
    }

    func save(accessToken: String?, refreshToken: String?) {
        UserDefaults.standard.set(accessToken, forKey: Keys.accessToken)
        UserDefaults.standard.set(refreshToken, forKey: Keys.refreshToken)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.removeObject(forKey: Keys.refreshToken)
    }
}

struct TokenPair {
    let accessToken: String
    let refreshToken: String?
}

protocol AuthRefresherProtocol: AnyObject {
    func refreshToken(using refreshToken: String?) async throws -> TokenPair
}
