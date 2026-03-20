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

public struct HTTPServerInfo: View {
    public let httpServerInfo: TLSKit.HTTPServerInfo
    @Binding var presentedView: InspectionResponseViewOptions?

    public var body: some View {
        Section(Localize.securityhttpheaders()) {
            ForEach(securityHeaders, id: \.self) { headerName in
                HTTPSecurityHeaderView(key: headerName, headers: httpServerInfo.headers)
            }

            let tag = InspectionResponseViewOptions.httpHeaders(httpServerInfo.headers)
            if #available(iOS 16, *) {
                viewAllLabel.tag(tag)
            } else {
                NavigationLink(tag: tag, selection: $presentedView) {
                    HTTPHeadersView(headers: httpServerInfo.headers)
                } label: {
                    viewAllLabel
                }
            }
        }
    }

    @ViewBuilder
    private var viewAllLabel: some View {
        HStack {
            Text(Localize.viewall())
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
}
