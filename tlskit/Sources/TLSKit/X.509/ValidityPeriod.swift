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

/// Describes a validity period
public struct ValidityPeriod: Sendable {
    /// The date at which this certificate becomes valid
    public let notBefore: Date
    /// The date at which this certificate ceases to be valid
    public let notAfter: Date

    /// The number of days this certificate is valid. Returns 0 if the validity period is less than 1 day.
    ///
    /// ``validFor`` should only be used for low precision checks.
    public var validFor: UInt32 {
        let durationSeconds = DateInterval(start: self.notBefore, end: self.notAfter).duration
        if durationSeconds < 86400 {
            return 0
        }

        return UInt32(DateInterval(start: self.notBefore, end: self.notAfter).duration / 86400)
    }

    /// If the current date falls within the validity period
    public var isValid: Bool {
        return !self.isNotYetValid && !self.isExpired
    }

    /// If the current date is before the validity period start
    public var isNotYetValid: Bool {
        return Date() < self.notBefore
    }

    /// If the current date is after the validity period ends
    public var isExpired: Bool {
        return Date() > self.notAfter
    }
}
