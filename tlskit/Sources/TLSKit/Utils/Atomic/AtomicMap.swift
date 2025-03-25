// TLSKit
// Copyright (C) 2024 Ian Spence
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

/// AtomicBool is a thread-safe map
internal final class AtomicMap<Key: Hashable, Value>: Sendable {
    nonisolated(unsafe) private var value: [Key: Value]
    nonisolated(unsafe) private var lock: NSObject = NSObject()

    /// Create a new thread-safe map with the initial value. The initial value can be an empty map.
    internal init(initialValue: [Key: Value]) {
        self.value = initialValue
    }

    /// Get the value for the given key
    /// - Parameter key: The element's key
    /// - Returns: The value or nil if the key was not present
    internal func Get(_ key: Key) -> Value? {
        objc_sync_enter(lock)
        let value = self.value[key]
        objc_sync_exit(lock)
        return value
    }

    /// Get a copy of the current map
    internal func All() -> [Key: Value] {
        objc_sync_enter(lock)
        let value = self.value
        objc_sync_exit(lock)
        return value
    }

    /// Set a value for the given key
    /// - Parameters:
    ///   - key: The element's key
    ///   - value: The element's value
    internal func Set(_ key: Key, _ value: Value) {
        objc_sync_enter(lock)
        self.value[key] = value
        objc_sync_exit(lock)
    }

    /// Delete the value for the given key
    /// - Parameter key: The element's key
    internal func Delete(_ key: Key) {
        objc_sync_enter(lock)
        self.value.removeValue(forKey: key)
        objc_sync_exit(lock)
    }

    /// Iterate over each item in the map
    ///
    /// Do not modify the map in the body as this will cause a deadlock.
    ///
    /// - Parameter body: Called for each item.
    internal func ForEach(_ body: (Key, Value) throws -> Void) {
        objc_sync_enter(lock)
        for (key, value) in self.value {
            do {
                try body(key, value)
            } catch {
                break
            }
        }
        objc_sync_exit(lock)
    }
}
