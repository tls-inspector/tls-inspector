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

/// AtomicVar is a thread-safe getter and setter for a variable
internal final class AtomicVar<T>: Sendable {
    nonisolated(unsafe) private var value: T?
    nonisolated(unsafe) private var lock: NSObject = NSObject()

    /// Create a new atomic integer with the given initial value
    /// - Parameter initialValue: The initial value for this variable
    public init(initialValue: T? = nil) {
        self.value = initialValue
    }

    /// Set the value of the variable to a new value
    public func Set(newValue: T?) {
        objc_sync_enter(lock)
        value = newValue
        objc_sync_exit(lock)
    }

    /// Get the current value of the variable
    public func Get() -> T? {
        objc_sync_enter(lock)
        let currentValue = self.value
        objc_sync_exit(lock)
        return currentValue
    }
}
