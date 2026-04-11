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
import TLSUI

/// Provides an interface for maintaining a list of recent inspections
@MainActor
internal final class InspectionHistoryManager {
    internal static let shared = InspectionHistoryManager()
    private let filePath: URL
    private let lock: NSObject = NSObject()
    private let maxHistoryCount = 10

    private init() {
        self.filePath = IO.fileInDocumentsDirectory("recent_inspections.json")
    }

    /// Get a list of all recent inspections. The returned list may be empty and will never contain more than 10 items.
    /// - Returns: A list of inspection requests
    internal func get() -> [InspectionRequest] {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        return getLocked()
    }

    private func getLocked() -> [InspectionRequest] {
        guard let data = try? Data.init(contentsOf: self.filePath) else {
            return []
        }

        do {
            return try JSONDecoder().decode([InspectionRequest].self, from: data)
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error decoding request history from file: \(error.localizedDescription)")
            return []
        }
    }

    private func write(_ requests: [InspectionRequest]) {
        do {
            let data = try JSONEncoder().encode(requests)
            try data.write(to: self.filePath)
            NotificationCenter.default.post(name: inspectionHistoryUpdated, object: nil)
        } catch {
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error writing request history to file: \(error.localizedDescription)")
        }
    }

    /// Add a new request to the list of recent requests. If the request is a duplicate of any existing item in the
    /// history that item is moved to the top of the list.
    /// - Parameter request: The request to add
    internal func add(_ request: InspectionRequest) {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        var requests = getLocked()

        var existingIndex: Int?
        for (i, r) in requests.enumerated() {
            if request != r {
                continue
            }
            existingIndex = i
            break
        }

        if let existingIndex = existingIndex {
            requests.remove(at: existingIndex)
        }
        requests.insert(request, at: 0)

        if requests.count > maxHistoryCount {
            requests.removeLast()
        }

        write(requests)
    }

    /// Remove the requests at the given set of indices
    /// - Parameter i: The indices of requests to remove
    internal func remove(atOffsets i: IndexSet) {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }

        var requests = getLocked()
        requests.remove(atOffsets: i)
        write(requests)
    }

    /// Remove all requests from the history
    internal func removeAll() {
        objc_sync_enter(self.lock)
        defer { objc_sync_exit(self.lock) }
        write([])
    }
}
