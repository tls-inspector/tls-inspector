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

public struct InspectionResponseView: View {
    public let response: InspectionResponse
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    TrustStatusView(status: response.tlsConnection.trust)
                }
                CertificateList(response: response)
                ConnectionInformation(response: response)
                if let httpServerInfo = response.httpServerInfo {
                    HTTPServerInfo(httpServerInfo: httpServerInfo)
                }
            }
            .navigationTitle(response.tlsConnection.domain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem {
                    Menu {
                        Button {
                            //
                        } label: {
                            Text(Localize.exportcertificatechain())
                        }
                        Divider()
                        Button {
                            //
                        } label: {
                            Text(Localize.viewonssllabs())
                        }
                        Button {
                            //
                        } label: {
                            Text(Localize.searchonshodan())
                        }
                        Button {
                            //
                        } label: {
                            Text(Localize.searchoncrtsh())
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
