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

import SwiftUI
import TLSKit

public struct TrustExplainationView: View {
    public let status: TrustStatus
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                TrustStatusView(status: status, showDetailsButton: false)
                Section("Trust Details") {
                    TitleValueView(title: "What does this mean?") {
                        Text("The server certificate for this site is trusted by the system because the root certificate authority is trusted.")
                    }
                    TitleValueView(title: "Is the connection to this site secure?") {
                        Text("Yes, your device has determined that the connection to this site is secure. However, it's important to keep in mind that a secure connection to a site does not mean that this site is safe or trustworthy.")
                    }
                }
            }
            .navigationTitle("Trust Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
