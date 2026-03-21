// TLSKit
// Copyright (C) Ian Spence and other TLSKit Contributors
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

/// A collection of HTTP headers.
///
/// HTTP header names are case-insensitive and duplicate headers are valid, so this class exists to provide a map-like interface.
public final class HTTPHeaders: Sendable, Equatable, Hashable {
    private let allHeaders = AtomicMap<String, [String]>(initialValue: [:])
    private let normalizedKeyMap = AtomicMap<String, String>(initialValue: [:])

    internal static func fromResponse(_ data: Data) -> HTTPHeaders {
        let lines = String(decoding: data, as: UTF8.self).split(separator: "\r\n")
        return HTTPHeaders.fromLines(lines)
    }

    internal static func fromLines(_ headerLines: [String.SubSequence]) -> HTTPHeaders {
        let headers = HTTPHeaders()
        for line in headerLines {
            let (name, value) = String(line).kvSplit()
            if name.isEmpty || value.isEmpty {
                printWarning("[\(#fileID):\(#line)] Ignoring invalid HTTP header line: \(line)")
                continue
            }

            headers.add(name, value)
        }

        return headers
    }

    internal static func fromMap(_ m: [String: String]) -> HTTPHeaders {
        let headers = HTTPHeaders()
        for (name, value) in m {
            headers.add(name, value)
        }
        return headers
    }

    /// Return all HTTP headers
    /// - Returns: A map of header name to values. Duplicate header use the name from the first occurance.
    public func all() -> [String: [String]] {
        return allHeaders.All()
    }

    /// Get a single value for the given header key.
    ///
    /// Does not guarantee any specific order if the header appears multiple times. Use ``get(_:)`` if order matters.
    ///
    /// - Parameter key: The header key
    /// - Returns: Any value if the header was present
    public func get1(_ key: String) -> String? {
        return get(key)?[0]
    }

    /// Get all values for the given header key
    /// - Parameter key: The header key
    /// - Returns: All values for the header if the key is present
    public func get(_ key: String) -> [String]? {
        guard let matchingKey = normalizedKeyMap.Get(key.lowercased()) else {
            return nil
        }

        return allHeaders.Get(matchingKey)
    }

    public static func == (lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
        return lhs.all() == rhs.all()
    }

    public func hash(into hasher: inout Hasher) {
        self.all().hash(into: &hasher)
    }

    internal func add(_ key: String, _ value: String) {
        if let existingKey = normalizedKeyMap.Get(key.lowercased()) {
            var newValue = allHeaders.Get(existingKey) ?? []
            newValue.append(value)
            allHeaders.Set(existingKey, newValue)
            return
        }

        normalizedKeyMap.Set(key.lowercased(), key)
        allHeaders.Set(key, [value])
    }
}
