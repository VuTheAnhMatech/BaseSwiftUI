//
//  CodableUtil.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 18/2/25.
//

import Foundation

struct CodableUtil<T: Decodable> {
    static func decodeFrom(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

    static func decodeJson(_ jsonString: String) -> T? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return decodeFrom(data)
    }
}

extension Encodable {
    func toString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }

        return String(data: data, encoding: .utf8)
    }

    func toJson() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
              ) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        guard let data = data(using: .utf8) else { return nil }

        do {
            return try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
