//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation
import Alamofire

final class APIService: APIServiceProtocol {
    static let shared = APIService(
        environment: .production,
        tokenStore: TokenStore.shared,
        refresher: nil
    )

    private let environment: APIEnvironment
    private let tokenStore: TokenStoreProtocol
    private let session: Session
    private let responseQueue = DispatchQueue(label: "network.response.queue", qos: .userInitiated)
    private let decodingQueue = DispatchQueue(label: "network.decoding.queue", qos: .userInitiated)

    init(
        environment: APIEnvironment,
        tokenStore: TokenStoreProtocol,
        refresher: AuthRefresherProtocol?,
        eventMonitors: [EventMonitor] = [LoggerNetwork()]
    ) {
        self.environment = environment
        self.tokenStore = tokenStore

        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 240
        configuration.timeoutIntervalForResource = 240
        configuration.waitsForConnectivity = false

        self.session = Session(
            configuration: configuration,
            interceptor: OAuth2Handler(tokenStore: tokenStore, refresher: refresher),
            eventMonitors: eventMonitors
        )
    }

    func request<T: APIRequestType>(_ request: T) async throws -> T.Response {
        guard let urlRequest = try? buildURLRequest(for: request) else {
            throw NetworkError.invalidURL
        }

        let data = try await perform(urlRequest, decoder: request.decoder, acceptableStatusCodes: request.acceptableStatusCodes)
        return try await decodeResponseAsync(T.Response.self, from: data, decoder: request.decoder)
    }

    func requestArray<T: APIRequestType>(_ request: T) async throws -> [T.Response] {
        guard let urlRequest = try? buildURLRequest(for: request) else {
            throw NetworkError.invalidURL
        }

        let data = try await perform(urlRequest, decoder: request.decoder, acceptableStatusCodes: request.acceptableStatusCodes)
        return try await decodeArrayAsync([T.Response].self, from: data, decoder: request.decoder)
    }

    func uploadMultipart<T: APIRequestType>(
        _ request: T,
        multipartDatas: [MultipartDataExt]
    ) async throws -> T.Response {
        guard let url = buildURL(path: request.path) else {
            throw NetworkError.invalidURL
        }

        var headers = mergedHeaders(for: request)
        headers.remove(name: "Content-Type")

        var uploadRequest: UploadRequest?

        let data = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                uploadRequest = session.upload(
                    multipartFormData: { formData in
                        multipartDatas.forEach { item in
                            formData.append(
                                item.data,
                                withName: item.name,
                                fileName: item.fileName,
                                mimeType: item.mimeType
                            )
                        }

                        request.queryParameters?.forEach { key, value in
                            if let data = "\(value)".data(using: .utf8) {
                                formData.append(data, withName: key)
                            }
                        }

                        if let body = request.body,
                           let encodedData = try? JSONEncoder().encode(AnyEncodable(body)),
                           let jsonObject = try? JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
                            jsonObject.forEach { key, value in
                                if let data = "\(value)".data(using: .utf8) {
                                    formData.append(data, withName: key)
                                }
                            }
                        }
                    },
                    to: url,
                    method: request.method,
                    headers: headers,
                    requestModifier: { urlRequest in
                        if let timeout = request.timeoutInterval {
                            urlRequest.timeoutInterval = timeout
                        }
                    }
                )

                uploadRequest?
                    .validate(statusCode: request.acceptableStatusCodes)
                    .responseData(queue: responseQueue) { response in
                        switch response.result {
                        case .success(let data):
                            continuation.resume(returning: data)
                        case .failure(let error):
                            continuation.resume(
                                throwing: self.mapAFError(
                                    error,
                                    data: response.data,
                                    statusCode: response.response?.statusCode
                                )
                            )
                        }
                    }
            }
        } onCancel: {
            uploadRequest?.cancel()
        }

        return try await decodeResponseAsync(T.Response.self, from: data, decoder: request.decoder)
    }
}

private extension APIService {
    func buildURL(path: String) -> URL? {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        return URL(string: environment.baseURL + path)
    }

    func buildURLRequest<T: APIRequestType>(for request: T) throws -> URLRequestConvertible {
        guard let url = buildURL(path: request.path) else {
            throw NetworkError.invalidURL
        }

        let headers = mergedHeaders(for: request)

        if let body = request.body {
            return try JSONRequestConvertible(
                url: url,
                method: request.method,
                headers: headers,
                body: AnyEncodable(body),
                timeoutInterval: request.timeoutInterval
            )
        } else {
            return try ParameterRequestConvertible(
                url: url,
                method: request.method,
                parameters: request.queryParameters,
                encoding: request.parameterEncoding,
                headers: headers,
                timeoutInterval: request.timeoutInterval
            )
        }
    }

    func mergedHeaders<T: APIRequestType>(for request: T) -> HTTPHeaders {
        var headers = request.headers
        headers["Accept"] = headers["Accept"] ?? "application/json"
        headers["X-Requires-Authorization"] = request.requiresAuthorization ? "true" : "false"

        if request.body != nil {
            headers["Content-Type"] = headers["Content-Type"] ?? "application/json"
        }

        return HTTPHeaders(headers)
    }

    func perform(
        _ urlRequest: URLRequestConvertible,
        decoder: JSONDecoder,
        acceptableStatusCodes: Range<Int>
    ) async throws -> Data {
        var dataRequest: DataRequest?

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                dataRequest = session.request(urlRequest)

                dataRequest?
                    .validate(statusCode: acceptableStatusCodes)
                    .responseData(queue: responseQueue) { response in
                        switch response.result {
                        case .success(let data):
                            continuation.resume(returning: data)
                        case .failure(let error):
                            continuation.resume(
                                throwing: self.mapAFError(
                                    error,
                                    data: response.data,
                                    statusCode: response.response?.statusCode
                                )
                            )
                        }
                    }
            }
        } onCancel: {
            dataRequest?.cancel()
        }
    }

    func decodeResponse<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder
    ) throws -> T {
        do {
            let decoded = try decoder.decode(type, from: data)
            try validateBusinessResponseIfNeeded(decoded)
            return decoded
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func decodeResponseAsync<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            decodingQueue.async {
                do {
                    let decoded = try decoder.decode(type, from: data)
                    try self.validateBusinessResponseIfNeeded(decoded)
                    continuation.resume(returning: decoded)
                } catch let error as NetworkError {
                    continuation.resume(throwing: error)
                } catch {
                    continuation.resume(throwing: NetworkError.decoding(error))
                }
            }
        }
    }

    func decodeArrayAsync<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            decodingQueue.async {
                do {
                    let decoded = try decoder.decode(type, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(throwing: NetworkError.decoding(error))
                }
            }
        }
    }

    func validateBusinessResponseIfNeeded<T: Decodable>(_ response: T) throws {
        if let response = response as? any BusinessResponseValidatable,
           !response.isBusinessSuccess {
            throw NetworkError.business(
                code: response.businessCode,
                message: response.businessMessage
            )
        }
    }

    func mapAFError(
        _ error: Error,
        data: Data? = nil,
        statusCode: Int? = nil
    ) -> NetworkError {
        if let afError = error as? AFError {
            if afError.isExplicitlyCancelledError {
                return .cancelled
            }

            if case .sessionTaskFailed(let underlying) = afError,
               let urlError = underlying as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return .noInternet
                case .timedOut:
                    return .timeout
                case .cancelled:
                    return .cancelled
                default:
                    break
                }
            }
        }

        if let statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            default:
                return .server(statusCode: statusCode, data: data)
            }
        }

        return .underlying(error)
    }
}

private struct ParameterRequestConvertible: URLRequestConvertible {
    let url: URL
    let method: HTTPMethod
    let parameters: Parameters?
    let encoding: ParameterEncoding
    let headers: HTTPHeaders
    let timeoutInterval: TimeInterval?

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: url, method: method, headers: headers)
        if let timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        return try encoding.encode(request, with: parameters)
    }
}

private struct JSONRequestConvertible: URLRequestConvertible {
    let url: URL
    let method: HTTPMethod
    let headers: HTTPHeaders
    let body: AnyEncodable
    let timeoutInterval: TimeInterval?

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: url, method: method, headers: headers)
        if let timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        return try JSONParameterEncoder.default.encode(body, into: request)
    }
}
