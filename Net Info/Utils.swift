//
//  Utils.swift
//  Net Info
//
//  Created by Afroz Alam on 02/04/26.
//

import Foundation

// This extension allows any Set containing Codable items (like String)
// to be saved directly into @AppStorage via JSON encoding.
extension Set: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        print("read")
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Set<Element>.self, from: data) else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        print("write")
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return result
    }
}
