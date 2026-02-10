// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import DNSKit
import TLSKit

/// Bridge between DNSKit's logger and TLSKit's logger, which are 1-to-1 compatible
public final class DNSKitLoggerBridge: DNSKit.ILogger {
    nonisolated(unsafe) public static let shared = DNSKitLoggerBridge()

    public func write(_ level: DNSKit.LogLevel, message: @autoclosure () -> String) {
        LogWriter.shared.write(TLSKit.LogLevel(rawValue: level.rawValue)!, message: message())
    }

    public func currentLevel() -> DNSKit.LogLevel? {
        return DNSKit.LogLevel(rawValue: LogWriter.shared.getLevel().rawValue)!
    }
}
