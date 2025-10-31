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

public struct ConnectionInformation: View {
    public let response: InspectionResponse

    public var body: some View {
        Section(Localize.connectioninformation()) {
            TitleValueView(title: Localize.negotiatedciphersuite()) {
                Text(String(describing: response.tlsConnection.ciphersuite))
                    .textSelection(.enabled)
            }
            TitleValueView(title: Localize.negotiatedversion()) {
                Text(response.tlsConnection.version.string())
                    .textSelection(.enabled)
            }
            TitleValueView(title: Localize.remoteaddress()) {
                Text(String(describing: response.tlsConnection.remoteAddress.string))
                    .textSelection(.enabled)
            }
            if let alpn = response.tlsConnection.alpn {
                TitleValueView(title: "ALPN") {
                    Text(alpn).textSelection(.enabled)
                }
            }
        }
    }
}
