// TLS Inspector
// Copyright (C) 2025 Ian Spence
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

public struct CertificateExtensionsView: View {
    public let extensions: [CertificateExtension]

    public init(extensions: [CertificateExtension]) {
        // We ignore these extensions in this list since we show them elsewhere
        let ignoredOids: [String] = [
            "2.5.29.14", // Subject key id
            "2.5.29.15", // Key usage
            "2.5.29.17", // Subject alt name
            "2.5.29.19", // Basic constraints
            "2.5.29.31", // CRL
            "2.5.29.32", // Certificate Policies
            "2.5.29.35", // Issuer key id
            "2.5.29.37", // Ext key usage
            "1.3.6.1.4.1.11129.2.4.2", // SCTs
        ]
        self.extensions = extensions.filter { ext in
            return ignoredOids.firstIndex(of: ext.oid) == nil
        }
    }

    public var body: some View {
        if !extensions.isEmpty {
            Section(Localize.extensions()) {
                ForEach(extensions, id: \.oid) { ext in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(ext.oid)
                                .font(.subheadline)
                                .opacity(0.5)
                            Spacer()
                            if ext.critical {
                                Image(systemName: "exclamationmark.circle")
                            }
                        }
                        Text(ext.value.hexEncodedString()).monospaced()
                    }
                }
            }
        }
    }
}
