//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation
import Alamofire

actor TokenRefreshCoordinator {
    private var refreshTask: Task<TokenPair, Error>?

    func refresh(
        refresher: AuthRefresherProtocol,
        refreshToken: String?
    ) async throws -> TokenPair {
        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task { try await refresher.refreshToken(using: refreshToken) }
        refreshTask = task

        do {
            let tokens = try await task.value
            refreshTask = nil
            return tokens
        } catch {
            refreshTask = nil
            throw error
        }
    }
}

final class OAuth2Handler: RequestInterceptor {
    private let tokenStore: TokenStoreProtocol
    private weak var refresher: AuthRefresherProtocol?
    private let coordinator = TokenRefreshCoordinator()

    init(
        tokenStore: TokenStoreProtocol,
        refresher: AuthRefresherProtocol? = nil
    ) {
        self.tokenStore = tokenStore
        self.refresher = refresher
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest

        let requiresAuthorization = request.value(forHTTPHeaderField: "X-Requires-Authorization") == "true"
        request.headers.remove(name: "X-Requires-Authorization")

        if requiresAuthorization,
           let token = tokenStore.accessToken,
           request.value(forHTTPHeaderField: "Authorization") == nil {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard
            let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            let refresher
        else {
            completion(.doNotRetry)
            return
        }

        Task {
            do {
                let tokens = try await coordinator.refresh(
                    refresher: refresher,
                    refreshToken: tokenStore.refreshToken
                )
                tokenStore.save(
                    accessToken: tokens.accessToken,
                    refreshToken: tokens.refreshToken
                )
                completion(.retry)
            } catch {
                tokenStore.clear()
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
