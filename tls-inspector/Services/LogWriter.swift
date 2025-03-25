// TLS Inspector
// Copyright (C) 2024 Ian Spence
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
internal final class LogWriter: ILogger {
    /// The shared instance of the logging facility.
    nonisolated(unsafe) static let shared = LogWriter()
    /// The minimum log level. Messages below this level are discarded. Can be modified at any time.
    nonisolated(unsafe) private var level: LogLevel

    private let filePath: URL
    private let fileWriter: FileHandle?
    private let lock: NSObject = NSObject()
    private var isOpen = false

    private init() {
        self.filePath = IO.fileInDocumentsDirectory("TLSKit.log")

        // Truncate the log if over 1M
        let size = IO.fileSize(self.filePath)
        if size > 1028*1028 {
            try? IO.delete(self.filePath)
        }

        if !IO.fileExists(self.filePath) {
            // Create a blank file for writing
            try? Data([]).write(to: self.filePath)
        }

        if let writer = try? FileHandle(forUpdating: self.filePath) {
            _ = try? writer.seekToEnd()
            self.fileWriter = writer
        } else {
            self.fileWriter = nil
        }
        self.isOpen = true
        self.level = LogWriter.defaultLogLevel()
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
    func setLevel(_ level: TLSKit.LogLevel) {
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
    func write(_ level: TLSKit.LogLevel, message: String) {
        if level.rawValue < self.level.rawValue {
            return
        }

        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        let message = "[\(level.string().uppercased())] [\(Date().ISO8601Format())] \(message)"
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

    func getLevel() -> TLSKit.LogLevel {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        return level
    }

    /// Close the log file. If the log file was not open take no action. Threadsafe.
    func close() {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        try? self.fileWriter?.synchronize()
        try? self.fileWriter?.close()
        self.isOpen = false
    }
}
