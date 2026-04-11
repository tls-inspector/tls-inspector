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

public struct CertificateStatusProvidersView: View {
    public let providers: [StatusProvider]
    public let statusResults: [CertificateStatus]?

    public var body: some View {
        Section(Localize.statusproviders()) {
            ForEach(providers, id: \.self) { provider in
                StatusView(provider: provider, result: self.statusResults?.first(where: { $0.informedBy == provider }))
            }
        }
    }
}

private struct StatusView: View {
    let provider: StatusProvider
    let result: CertificateStatus?

    public var body: some View {
        VStack(alignment: .leading) {
            switch provider {
            case .crl(let url):
                TitleValueView(title: "CRL") {
                    Text(url)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            case .ocsp(let url):
                TitleValueView(title: "OCSP") {
                    Text(url)
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            }
            if let result = self.result {
                HStack {
                    if result.revoked {
                        Image(systemName: "multiply.circle.fill").foregroundStyle(.red)
                        Text(Localize.revokedreason(reason: result.revocationReason?.rawValue ?? "unknown"))
                    } else {
                        Image(systemName: "checkmark.circle").foregroundStyle(.green)
                        Text(Localize.notrevoked())
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}
