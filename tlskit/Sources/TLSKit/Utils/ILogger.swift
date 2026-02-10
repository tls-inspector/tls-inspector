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

/// Log message levels
public enum LogLevel: Int, Comparable {
    case Debug = 0
    case Information = 1
    case Warning = 2
    case Error = 3

    public func string() -> String {
        return String(describing: self)
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Describes a protocol for recieving log events from TLSKit
public protocol ILogger {
    /// Write a new line to the log
    /// - Parameters:
    ///   - level: The level of the message
    ///   - message: The log message
    func write(_ level: LogLevel, message: @autoclosure () -> String)

    /// Return the current log facility level.
    /// - Returns: The current log level
    func getLevel() -> LogLevel
}

/// The logging facility used by DNSKit. Defaults to an internal interface that just calls `print()`.
/// This should only be set once, preferably during startup of the application, and must never be changed once TLSKit is used.
nonisolated(unsafe) public var log: ILogger? = PrintLogger()

internal func printDebug(_ message: @autoclosure () -> String) {
    log?.write(.Debug, message: message())
}

internal func printInformation(_ message: @autoclosure () -> String) {
    log?.write(.Information, message: message())
}

internal func printWarning(_ message: @autoclosure () -> String) {
    log?.write(.Warning, message: message())
}

internal func printError(_ message: @autoclosure () -> String) {
    log?.write(.Error, message: message())
}

internal struct PrintLogger: ILogger {
    internal let dateFormatter = DateFormatter.iso8601()

    func write(_ level: LogLevel, message: @autoclosure () -> String) {
        if getLevel() <= level {
            print("[\(level.string().uppercased())] [\(dateFormatter.string(from: Date()))] \(message())")
        }
    }

    func getLevel() -> LogLevel {
        return .Debug
    }
}

internal func logOpenSSLError(inFile: String, atLine: Int) {
    var opensslFile: UnsafePointer<CChar>?
    var opensslLine: Int32 = -1
    let errorCode = ERR_get_error()
    ERR_peek_last_error_line(&opensslFile, &opensslLine)
    if opensslFile == nil {
        printError("[\(inFile):\(atLine)] (\(errorCode)) Unsuccessful OpenSSL operation but no value returned from ERR_peek_last_error_line")
    } else {
        let fileName = String(cString: opensslFile!)
        printError("[\(inFile):\(atLine)] (\(errorCode)) OpenSSL error in \(fileName):\(opensslLine)")
    }
}
