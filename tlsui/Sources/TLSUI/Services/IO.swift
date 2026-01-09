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

/// Provides a basic filesystem interface
public class IO {
    /// Return a file path for a file with `name` in the documents directory of the app
    /// - Parameter name: The file name to use
    /// - Returns: A URL pointing to the file path
    public static func fileInDocumentsDirectory(_ name: String) -> URL {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if #available(iOS 16, *) {
            return basePath.appending(path: name)
        } else {
            return basePath.appendingPathComponent(name)
        }
    }

    /// Returns true if the given path exists
    /// - Parameter path: The path of the file or directory
    /// - Returns: True if a file or directory exists at the given path
    public static func fileExists(_ path: URL) -> Bool {
        if #available(iOS 16, *) {
            return FileManager.default.fileExists(atPath: path.path())
        } else {
            return FileManager.default.fileExists(atPath: path.path)
        }
    }

    /// Returns the size of the file at `path`
    /// - Parameter path: The file path
    /// - Returns: The file size or 0
    public static func fileSize(_ path: URL) -> Int64 {
        let attributes: [FileAttributeKey: Any]
        do {
            if #available(iOS 16, *) {
                attributes = try FileManager.default.attributesOfItem(atPath: path.path())
            } else {
                attributes = try FileManager.default.attributesOfItem(atPath: path.path)
            }
        } catch {
            return 0
        }

        guard let itemSize = attributes[FileAttributeKey.size] as? Int64 else {
            return 0
        }

        return itemSize
    }

    /// Delete the file or directory located at `path`
    /// - Parameter path: The path of the item to remove
    public static func delete(_ path: URL) throws {
        try FileManager.default.removeItem(at: path)
    }
}
