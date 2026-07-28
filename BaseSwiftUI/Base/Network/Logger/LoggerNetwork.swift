//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation
import Alamofire

final class LoggerNetwork: EventMonitor {
    let queue = DispatchQueue(label: "network.logger.queue")
    private let maxBodyLogBytes = 12_000

    func requestDidResume(_ request: Request) {
        #if DEBUG
        let method = request.request?.httpMethod ?? ""
        let url = request.request?.url?.absoluteString ?? ""
        print("➡️ [Request] \(method) \(url)")
        if let headers = request.request?.allHTTPHeaderFields {
            print("Headers:", redactedHeaders(headers))
        }
        if let body = request.request?.httpBody {
            print("Body: <\(body.count) bytes>")
        }
        #endif
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        if let statusCode = response.response?.statusCode {
            print("⬅️ [Response] status:", statusCode)
        }

        if let data = response.data {
            if data.count > maxBodyLogBytes {
                print("Response Body: <\(data.count) bytes>")
            } else if let object = try? JSONSerialization.jsonObject(with: data),
                      let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                      let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            } else if let text = String(data: data, encoding: .utf8) {
                print(text)
            }
        }

        if let error = response.error {
            print("❌ [Error]", error)
        }
        #endif
    }

    private func redactedHeaders(_ headers: [String: String]) -> [String: String] {
        let sensitiveNames = Set([
            "authorization",
            "cookie",
            "set-cookie",
            "x-api-key",
            "x-goog-api-key",
            "x-simulator-bypass-token"
        ])

        return headers.reduce(into: [:]) { result, header in
            result[header.key] = sensitiveNames.contains(header.key.lowercased())
                ? "<redacted>"
                : header.value
        }
    }
}
