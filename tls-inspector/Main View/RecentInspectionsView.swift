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

import SwiftUI
import TLSKit
import TLSUI
import Localization

struct RecentInspectionsView: View {
    let onSelect: (InspectionRequest) -> Void
    @State private var showRecentRequests = UserOptions.current.rememberRecentLookups
    @State private var recentRequests = InspectionHistoryManager.shared.get()

    var body: some View {
        Group {
            if showRecentRequests && !recentRequests.isEmpty {
                Section(Localize.recentlookups()) {
                    ForEach(recentRequests, id: \.description) { request in
                        RecentInspectionListItem(request: request, onSelect: self.onSelect)
                    }
                    .onDelete { idxSet in
                        InspectionHistoryManager.shared.remove(atOffsets: idxSet)
                    }
                }
            } else {
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: optionsChangedNotification)) { _ in
            showRecentRequests = UserOptions.current.rememberRecentLookups
        }
        .onReceive(NotificationCenter.default.publisher(for: inspectionHistoryUpdated)) { _ in
            recentRequests = InspectionHistoryManager.shared.get()
        }
    }
}

private struct RecentInspectionListItem: View {
    let request: InspectionRequest
    let onSelect: (InspectionRequest) -> Void

    public var body: some View {
        ListButton {
            onSelect(request)
        } label: {
            VStack(alignment: .leading) {
                if let serverName = request.serverName {
                    Text(serverName)
                    Text(request.address).font(.caption)
                } else {
                    Text(request.address)
                }
            }
        }
    }
}
