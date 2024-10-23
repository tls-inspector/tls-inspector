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

private let securityHeaders = [
    "Content-Security-Policy",
    "Cross-Origin-Opener-Policy",
    "Cross-Origin-Resource-Policy",
    "Permissions-Policy",
    "Referrer-Policy",
    "Strict-Transport-Security",
    "X-Content-Type-Options",
    "X-Frame-Options",
]

public struct InspectionResponseView: View {
    public let response: InspectionResponse
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    TrustStatusView(status: response.tlsConnection.trust)
                }
                Section("Certificates") {
                    ForEach(response.tlsConnection.certificates, id: \.subject.description) { certificate in
                        NavigationLink {
                            CertificateView(certificate: certificate)
                        } label: {
                            HStack {
                                Text(certificate.subject.description)
                                if certificate.isCA && certificate.subject == certificate.issuer {
                                    Spacer()
                                    Text("Root").opacity(0.5)
                                }
                            }
                        }
                    }
                }
                Section("Connection Information") {
                    TitleValueView(title: "Negotiated Ciphersuite") {
                        Text(String(describing: response.tlsConnection.ciphersuite))
                    }
                    TitleValueView(title: "Negotiated Version") {
                        Text(response.tlsConnection.version.string())
                    }
                    TitleValueView(title: "Remote Address") {
                        Text(String(describing: response.tlsConnection.remoteAddress.string))
                    }
                }
                if let httpServerInfo = response.httpServerInfo {
                    Section("Security HTTP Headers") {
                        ForEach(securityHeaders, id: \.self) { headerName in
                            HTTPSecurityHeaderView(key: headerName, headers: httpServerInfo.headers)
                        }
                        NavigationLink {
                            HTTPHeadersView(headers: httpServerInfo.headers)
                        } label: {
                            Text("View All")
                        }
                    }
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
            }
        }
    }
}
