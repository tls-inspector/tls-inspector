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

public struct CertificateList: View {
    public let response: InspectionResponse
    @Binding var presentedView: InspectionResponseViewOptions?

    public var body: some View {
        Section(Localize.certificates()) {
            ForEach(response.tlsConnection.certificates) { certificate in
                let tag = InspectionResponseViewOptions.certificate(certificate)
                if #available(iOS 16, *) {
                    CertificateListRowLabel(certificate: certificate).tag(tag)
                } else {
                    NavigationLink(tag: tag, selection: $presentedView) {
                        CertificateView(certificate: certificate)
                    } label: {
                        CertificateListRowLabel(certificate: certificate)
                    }
                }
            }
        }
    }
}

private struct CertificateListRowLabel: View {
    public let certificate: Certificate

    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(certificate.description ?? Localize.unnamedcertificate())
                if let source = certificate.source {
                    Text(source == .server ? Localize.sentbyserver() : Localize.foundondevice())
                        .opacity(0.5)
                        .font(.subheadline)
                }
            }
            Spacer()
            HStack {
                if certificate.isCA && certificate.subject == certificate.issuer {
                    Text(Localize.root()).opacity(0.5)
                }
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
