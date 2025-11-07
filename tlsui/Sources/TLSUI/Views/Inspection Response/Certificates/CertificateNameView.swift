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

public struct CertificateSubjectView: View {
    public let subject: Name
    public let alternateNames: [AlternateName]?

    public var body: some View {
        CertificateNameView(title: Localize.subject(), name: self.subject, alternateNames: self.alternateNames)
    }
}

public struct CertificateIssuerView: View {
    public let issuer: Name

    public var body: some View {
        CertificateNameView(title: Localize.issuer(), name: self.issuer, alternateNames: nil)
    }
}

private struct CertificateNameView: View {
    public let title: String
    public let name: Name
    public let alternateNames: [AlternateName]?

    public var body: some View {
        Section(self.title) {
            ForEach(name.commonName, id: \.self) { cn in
                TitleValueView(title: Localize.commonname()) {
                    Text(cn)
                        .textSelection(.enabled)
                }
            }
            ForEach(name.country, id: \.self) { c in
                TitleValueView(title: Localize.country()) {
                    Text(c)
                        .textSelection(.enabled)
                }
            }
            ForEach(name.locality, id: \.self) { l in
                TitleValueView(title: Localize.citylocality()) {
                    Text(l)
                        .textSelection(.enabled)
                }
            }
            ForEach(name.state, id: \.self) { s in
                TitleValueView(title: Localize.stateprovince()) {
                    Text(s)
                        .textSelection(.enabled)
                }
            }
            ForEach(name.organization, id: \.self) { o in
                TitleValueView(title: Localize.organization()) {
                    Text(o)
                        .textSelection(.enabled)
                }
            }
            ForEach(name.organizationUnit, id: \.self) { ou in
                TitleValueView(title: Localize.organizationalunit()) {
                    Text(ou)
                        .textSelection(.enabled)
                }
            }
            if let sans = alternateNames {
                NavigationLink {
                    AlternateNameView(alternateNames: sans)
                } label: {
                    HStack {
                        Text(Localize.alternatenames())
                        Spacer()
                        Text("\(sans.count)").opacity(0.5)
                    }
                }
            }
        }
    }
}
