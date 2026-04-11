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
import TLSKit

/// Describes the logging facility for DNS Inspector.
///
/// > Warning: Do not create more than once instance of this class. Only use the `LogWriter.shared` singleton.
public final class LogWriter: ILogger {
    /// The shared instance of the logging facility.
    nonisolated(unsafe) public static let shared = LogWriter()
    /// The minimum log level. Messages below this level are discarded. Can be modified at any time.
    nonisolated(unsafe) private var level: LogLevel

    public let filePath: URL
    private let lock: NSObject = NSObject()
    private var fileWriter: FileHandle?
    private var isOpen = false

    private init() {
        let filePath = IO.fileInDocumentsDirectory("TLSKit.log")
        self.filePath = filePath

        if let writer = LogWriter.open(filePath: filePath) {
            self.fileWriter = writer
            self.isOpen = true
        } else {
            self.fileWriter = nil
            self.isOpen = false
        }
        self.level = LogWriter.defaultLogLevel()
    }

    private static func open(filePath: URL) -> FileHandle? {
        // Truncate the log if over 1M
        let size = IO.fileSize(filePath)
        if size > 1028*1028 {
            try? IO.delete(filePath)
        }

        if !IO.fileExists(filePath) {
            // Create a blank file for writing
            try? Data([]).write(to: filePath)
        }

        if let writer = try? FileHandle(forUpdating: filePath) {
            _ = try? writer.seekToEnd()
            return writer
        }

        return nil
    }

    /// Returns the default log level to use.
    ///
    /// On debug configurations the level is `Debug`, on release configurations it is `Error`.
    /// - Returns: A log level
    static func defaultLogLevel() -> LogLevel {
#if DEBUG
        return .Debug
 #else
        return .Error
 #endif
    }

    /// Update the current logging level
    /// - Parameter level: The new level to use
    public func setLevel(_ level: TLSKit.LogLevel) {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }
        self.level = level
    }

    /// Write a new event to the log. Events are printed to the console as well as saved in the log file. Threadsafe.
    ///
    /// Will only capture the event if the level is at or above the level of the logging facility.
    /// - Parameters:
    ///   - level: The level of the event
    ///   - message: The message to write
    public func write(_ level: TLSKit.LogLevel, message: @autoclosure () -> String) {
        if level.rawValue < self.level.rawValue {
            return
        }

        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        let message = "[\(level.string().uppercased())] [\(Date().ISO8601Format())] \(message())"
        print(message)
        if !self.isOpen {
            return
        }
        guard let writer = self.fileWriter else {
            return
        }
        guard var data = message.data(using: .utf8) else {
            return
        }
        data.append(Data([0x0a]))
        try? writer.write(contentsOf: data)
    }

    public func getLevel() -> TLSKit.LogLevel {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        return level
    }

    /// Close the log file. If the log file was not open take no action. Threadsafe.
    public func close() {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        try? self.fileWriter?.synchronize()
        try? self.fileWriter?.close()
        self.isOpen = false
    }

    /// Delete the current log file and open a fresh empty file. Threadsafe.
    public func truncate() throws {
        guard let fileWriter = self.fileWriter else {
            return
        }

        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        try fileWriter.synchronize()
        try fileWriter.close()
        self.fileWriter = nil
        self.isOpen = false
        try IO.delete(self.filePath)

        guard let writer = LogWriter.open(filePath: self.filePath) else {
            return
        }

        self.fileWriter = writer
        self.isOpen = true
    }
}
