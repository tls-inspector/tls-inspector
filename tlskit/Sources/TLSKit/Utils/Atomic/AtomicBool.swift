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

/// AtomicBool is a thread-safe boolean value
public final class AtomicBool: Sendable {
    nonisolated(unsafe) private var value: Bool
    nonisolated(unsafe) private var lock: NSObject = NSObject()

    /// Create a new atomic boolean with the given initial value
    /// - Parameter initialValue: The initial value for this boolean
    internal init(initialValue: Bool) {
        self.value = initialValue
    }

    /// Set the value of the boolean to this new value
    /// - Parameter newValue: The new value of the boolean
    internal func Set(newValue: Bool) {
        objc_sync_enter(lock)
        value = newValue
        objc_sync_exit(lock)
    }

    /// Get a copy of the current value of the boolean
    /// - Returns: A copy of the current value of the boolean
    internal func Get() -> Bool {
        objc_sync_enter(lock)
        let currentValue = self.value
        objc_sync_exit(lock)
        return currentValue
    }

    /// Execute an action if the current value of the boolean meets the condition.
    /// The action is performed on the same thread as the caller and has exclusive ownership of the boolean during execution.
    /// Sets the value of the boolean to the return value of the action.
    /// - Parameters:
    ///   - condition: The value of which the boolean must be for action to be executed.
    ///   - action: The action to execute if the condition is true. Return a desired value for the boolean.
    internal func If(_ condition: Bool, _ action: @escaping () -> Bool) {
        objc_sync_enter(lock)
        if value == condition {
            let newValue = action()
            value = newValue
        }
        objc_sync_exit(lock)
    }
}
