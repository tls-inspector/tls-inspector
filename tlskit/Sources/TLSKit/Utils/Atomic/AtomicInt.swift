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

/// AtomicInt is a thread-safe integer
public final class AtomicInt: Sendable {
    nonisolated(unsafe) private var value: Int
    nonisolated(unsafe) private var lock: NSObject = NSObject()

    /// Create a new atomic integer with the given initial value
    /// - Parameter initialValue: The initial value for this integer
    public init(initialValue: Int) {
        self.value = initialValue
    }

    /// Set the value of the integer to a new value
    public func Set(newValue: Int) {
        objc_sync_enter(lock)
        value = newValue
        objc_sync_exit(lock)
    }

    /// Increment the integer and return its new value
    /// - Parameter amount: Optionally specify how much to increment by. Defaults to 1. Do not specify a negative number.
    /// - Returns: The new value of the integer after incrementing.
    public func IncrementAndGet(amount: Int = 1) -> Int {
        objc_sync_enter(lock)
        value += amount
        let newValue = value
        objc_sync_exit(lock)
        return newValue
    }

    /// Decrements the integer and return its new value
    /// - Parameter amount: Optionally specify how much to decrement by. Defaults to 1. Do not specify a negative number.
    /// - Returns: The new value of the integer after decrementing.
    public func DecrementAndGet(amount: Int = 1) -> Int {
        objc_sync_enter(lock)
        value -= amount
        let newValue = value
        objc_sync_exit(lock)
        return newValue
    }

    /// Get the current value of the integer
    public func Get() -> Int {
        objc_sync_enter(lock)
        let currentValue = self.value
        objc_sync_exit(lock)
        return currentValue
    }
}
