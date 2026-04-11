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

struct AlternateNameView: View {
    let alternateNames: [AlternateName]

    var body: some View {
        List {
            ForEach(alternateNames, id: \.self) { name in
                switch name {
                case .dns(let dns):
                    TitleValueView(title: Localize.dnsname()) {
                        Text(dns)
                            .textSelection(.enabled)
                    }
                case .email(let email):
                    TitleValueView(title: Localize.emailaddress()) {
                        Text(email)
                            .textSelection(.enabled)
                    }
                case .ipAddress(let ip):
                    TitleValueView(title: Localize.ipaddress()) {
                        Text(ip.string)
                            .textSelection(.enabled)
                    }
                case .uri(let uri):
                    TitleValueView(title: Localize.uri()) {
                        Text(uri)
                            .textSelection(.enabled)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Localize.alternatenames())
    }
}
