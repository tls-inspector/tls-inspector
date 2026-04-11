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
import OpenSSL

internal extension TimeZone {
    static var utc: TimeZone {
        return TimeZone(secondsFromGMT: 0)!
    }
}

internal extension Date {
    static func from(ASN1_GENERALIZEDTIME o: UnsafePointer<ASN1_GENERALIZEDTIME>) -> Date? {
        guard let expiryTimeStr = NSString(utf8String: ASN1_STRING_get0_data(o)) else {
            return nil
        }

        guard let year = Int(expiryTimeStr.substring(with: NSRange(location: 0, length: 4))) else {
            return nil
        }
        guard let month = Int(expiryTimeStr.substring(with: NSRange(location: 4, length: 2))) else {
            return nil
        }
        guard let day = Int(expiryTimeStr.substring(with: NSRange(location: 6, length: 2))) else {
            return nil
        }
        let hour = Int(expiryTimeStr.substring(with: NSRange(location: 8, length: 2))) ?? 0
        let minute = Int(expiryTimeStr.substring(with: NSRange(location: 10, length: 2))) ?? 0
        let second = Int(expiryTimeStr.substring(with: NSRange(location: 12, length: 2))) ?? 0

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.timeZone = TimeZone.utc

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.utc

        guard let date = calendar.date(from: dateComponents) else {
            return nil
        }

        return date
    }

    static func from(ASN1_TIME o: UnsafePointer<ASN1_TIME>) -> Date? {
        guard let data = ASN1_TIME_to_generalizedtime(o, nil) else {
            return nil
        }
        defer { ASN1_GENERALIZEDTIME_free(data) }
        return Date.from(ASN1_GENERALIZEDTIME: data)
    }
}
