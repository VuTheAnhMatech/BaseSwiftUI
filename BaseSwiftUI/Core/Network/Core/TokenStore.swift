// Created by Vu The Anh

import Foundation

protocol TokenStoreProtocol: AnyObject {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func save(accessToken: String?, refreshToken: String?) throws
    func clear() throws
}

final class TokenStore: TokenStoreProtocol {
    static let shared = TokenStore()

    private let storage: any SecureTokenStorage
    private let legacyDefaults: UserDefaults
    private let lock = NSLock()
    private var pendingClear = false

    init(storage: any SecureTokenStorage = KeychainTokenStorage(
        service: (Bundle.main.bundleIdentifier ?? "BaseSwiftUI") + ".authentication"
    ), legacyDefaults: UserDefaults = .standard) {
        self.storage = storage
        self.legacyDefaults = legacyDefaults
    }

    private enum Keys {
        static let accessToken = "network.accessToken"
        static let refreshToken = "network.refreshToken"
    }

    var accessToken: String? { readTokens()?.accessToken }
    var refreshToken: String? { readTokens()?.refreshToken }

    func save(accessToken: String?, refreshToken: String?) throws {
        if accessToken == nil && refreshToken == nil {
            try clear()
            return
        }
        lock.lock()
        defer { lock.unlock() }
        let tokens = StoredTokens(accessToken: accessToken, refreshToken: refreshToken)
        try storage.write(JSONEncoder().encode(tokens))
        pendingClear = false
        removeLegacyTokens()
    }

    func clear() throws {
        lock.lock()
        defer { lock.unlock() }
        pendingClear = true
        removeLegacyTokens()
        try storage.delete()
        pendingClear = false
    }

    private func readTokens() -> StoredTokens? {
        lock.lock()
        defer { lock.unlock() }
        do {
            // A failed logout deletion must not expose the old credential in this process.
            if pendingClear {
                try storage.delete()
                pendingClear = false
                return nil
            }
            if let data = try storage.read() {
                let tokens = try JSONDecoder().decode(StoredTokens.self, from: data)
                removeLegacyTokens()
                return tokens
            }
            let access = legacyDefaults.string(forKey: Keys.accessToken)
            let refresh = legacyDefaults.string(forKey: Keys.refreshToken)
            guard access != nil || refresh != nil else { return nil }
            let tokens = StoredTokens(accessToken: access, refreshToken: refresh)
            try storage.write(JSONEncoder().encode(tokens))
            removeLegacyTokens()
            return tokens
        } catch {
            Log.error("Secure token storage unavailable", category: "authentication")
            return nil
        }
    }

    private func removeLegacyTokens() {
        legacyDefaults.removeObject(forKey: Keys.accessToken)
        legacyDefaults.removeObject(forKey: Keys.refreshToken)
    }
}

struct TokenPair {
    let accessToken: String
    let refreshToken: String?
}

protocol AuthRefresherProtocol: AnyObject {
    func refreshToken(using refreshToken: String?) async throws -> TokenPair
}
