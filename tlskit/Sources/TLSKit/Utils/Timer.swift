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

/// Describes a timer for measuring the duration of an operation
internal final class Timer: Sendable {
    private let startTime: DispatchTime

    private init(startTime: DispatchTime) {
        self.startTime = startTime
    }

    /// Create and start a new timer
    internal static func start() -> Timer {
        return Timer(startTime: DispatchTime.now())
    }

    /// Stop the timer and return the number of nanoseconds since the timer started
    internal func stop() -> UInt64 {
        let endTime = DispatchTime.now()
        return endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
    }
}
