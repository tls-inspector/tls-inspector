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

public struct CertificateIssuerView: View {
    public let issuer: Name

    public var body: some View {
        Section("Issuer") {
            ForEach(issuer.commonName, id: \.self) { cn in
                TitleValueView(title: "Common Name") {
                    Text(cn)
                }
            }
            ForEach(issuer.country, id: \.self) { c in
                TitleValueView(title: "Country") {
                    Text(c)
                }
            }
            ForEach(issuer.locality, id: \.self) { l in
                TitleValueView(title: "City / Locality") {
                    Text(l)
                }
            }
            ForEach(issuer.state, id: \.self) { s in
                TitleValueView(title: "State / Province") {
                    Text(s)
                }
            }
            ForEach(issuer.organization, id: \.self) { o in
                TitleValueView(title: "Organization") {
                    Text(o)
                }
            }
            ForEach(issuer.organizationUnit, id: \.self) { ou in
                TitleValueView(title: "Organizational Unit") {
                    Text(ou)
                }
            }
        }
    }
}
