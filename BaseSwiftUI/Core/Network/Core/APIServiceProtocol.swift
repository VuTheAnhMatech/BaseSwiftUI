//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

protocol APIServiceProtocol {
    func request<T: APIRequestType>(_ request: T) async throws -> T.Response
    func requestArray<T: APIRequestType>(_ request: T) async throws -> [T.Response]
    func uploadMultipart<T: APIRequestType>(
        _ request: T,
        multipartDatas: [MultipartDataExt]
    ) async throws -> T.Response
}
