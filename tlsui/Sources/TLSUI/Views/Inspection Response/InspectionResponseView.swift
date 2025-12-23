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
import Localization

internal enum InspectionResponseViewOptions: Hashable {
    case certificate(Certificate)
    case httpHeaders(HTTPHeaders)
}

public struct InspectionResponseView: View {
    public let response: InspectionResponse
    @State private var presentedView: InspectionResponseViewOptions
    @Environment(\.dismiss) private var dismiss

    public init(response: InspectionResponse) {
        self.response = response
        self.presentedView = .certificate(response.tlsConnection.certificates[0])
    }

    public var body: some View {
        SplitView {
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
            .listStyle(.insetGrouped)
            .navigationTitle(response.tlsConnection.domain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        NotificationCenter.default.post(name: closedInspectionViewNotification, object: nil)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem {
                    Menu {
                        Button {
                            // TODO
                        } label: {
                            Text(Localize.exportcertificatechain())
                        }
                        Divider()
                        Link(destination: URL(string: "https://www.ssllabs.com/ssltest/analyze.html?d=\(response.tlsConnection.domain)&hideResults=on")!) {
                            Text(Localize.viewonssllabs())
                        }
                        Link(destination: URL(string: "https://www.shodan.io/host/\(response.tlsConnection.remoteAddress)")!) {
                            Text(Localize.searchonshodan())
                        }
                        Link(destination: URL(string: "https://crt.sh/?q=\(response.tlsConnection.domain)")!) {
                            Text(Localize.searchoncrtsh())
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        } content: {
            Navigation {
                switch self.presentedView {
                case .certificate(let certificate):
                    CertificateView(certificate: certificate)
                case .httpHeaders(let headers):
                    HTTPHeadersView(headers: headers)
                }
            }
        }
    }
}
