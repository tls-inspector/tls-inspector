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

/// AtomicArray is a thread safe mutable array
public final class AtomicArray<T>: Sendable {
    nonisolated(unsafe) fileprivate var value: [T]
    nonisolated(unsafe) fileprivate var lock: NSObject = NSObject()

    /// Create a new atomic array with the given initial value.
    /// - Parameter initialValue: The initial value. This can be an empty array.
    public init(initialValue: [T]) {
        self.value = initialValue
    }

    /// Get the value at the given index of the array
    /// - Parameter index: The index of the element
    /// - Returns: The value of the element
    public func Get(_ index: Int) -> T {
        objc_sync_enter(lock)
        let currentValue = self.value[index]
        objc_sync_exit(lock)
        return currentValue
    }

    /// Get a copy of the current value of the array
    public func Get() -> [T] {
        objc_sync_enter(lock)
        let currentValues = self.value
        objc_sync_exit(lock)
        return currentValues
    }

    /// Get the value at the given index of the array. If that index is out of bounds, returns nil.
    /// - Parameter index: The index of the element
    /// - Returns: The value of the element or nil if the index is out of bounds.
    public func TryGet(_ index: Int) -> T? {
        objc_sync_enter(lock)
        let currentValue: T?
        if index > self.value.count - 1 {
            currentValue = nil
        } else {
            currentValue = self.value[index]
        }
        objc_sync_exit(lock)
        return currentValue
    }

    /// Get the count of elements in the array
    public func Count() -> Int {
        objc_sync_enter(lock)
        let currentCount = self.value.count
        objc_sync_exit(lock)
        return currentCount
    }

    /// Perform a for each loop on the array.
    ///
    /// Do not modify the array from within the loop, as it will cause a dead lock
    ///
    /// - Parameter f: Called for each element in the array. If an error is thrown then the loop is cancelled.
    public func ForEach(_ f: ((T) throws -> Void)) {
        objc_sync_enter(lock)
        for value in self.value {
            do {
                try f(value)
            } catch {
                break
            }
        }
        objc_sync_exit(lock)
    }

    /// Set the value of the given index for the array
    /// - Parameters:
    ///   - index: The index of the element
    ///   - value: The value of the element
    public func Set(_ index: Int, _ value: T) {
        objc_sync_enter(lock)
        self.value[index] = value
        objc_sync_exit(lock)
    }

    /// Append a new value to the end of the array
    public func Append(_ value: T) {
        objc_sync_enter(lock)
        self.value.append(value)
        objc_sync_exit(lock)
    }

    /// Remove the element at the specified index
    public func Remove(at index: Int) {
        objc_sync_enter(lock)
        self.value.remove(at: index)
        objc_sync_exit(lock)
    }
}
