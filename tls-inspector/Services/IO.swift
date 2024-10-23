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

public class IO {
    public static func fileInDocumentsDirectory(_ name: String) -> URL {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if #available(iOS 16, *) {
            return basePath.appending(path: name)
        } else {
            return basePath.appendingPathComponent(name)
        }
    }

    public static func fileExists(_ path: URL) -> Bool {
        if #available(iOS 16, *) {
            return FileManager.default.fileExists(atPath: path.path())
        } else {
            return FileManager.default.fileExists(atPath: path.path)
        }
    }

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

    public static func delete(_ path: URL) throws {
        try FileManager.default.removeItem(at: path)
    }

    public static func read(_ path: URL) throws -> Data {
        return try Data(contentsOf: path)
    }

    public static func write(_ path: URL, data: Data) throws {
        return try data.write(to: path)
    }
}
