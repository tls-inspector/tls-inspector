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

public struct CertificateTimestampView: View {
    public let timestamps: [SignedCertificateTimestamp]

    public var body: some View {
        List {
            ForEach(timestamps, id: \.logId) { timestamp in
                Section {
                    TitleValueView(title: Localize.logid()) {
                        Text(timestamp.logId.hexEncodedString())
                            .fixedwidth()
                            .textSelection(.enabled)
                    }
                    if let logName = timestamp.logName {
                        TitleValueView(title: Localize.logname()) {
                            Text(logName)
                                .textSelection(.enabled)
                        }
                    }
                    HStack {
                        Text(Localize.timestamps()).opacity(0.5)
                        Spacer()
                        Text(timestamp.timestamp.utcFormatted())
                    }
                    HStack {
                        Text(Localize.signaturetype()).opacity(0.5)
                        Spacer()
                        Text(timestamp.signatureAlgorithm.string())
                    }
                    TitleValueView(title: Localize.signature()) {
                        Text(timestamp.signature.hexEncodedString()).fixedwidth()
                    }
                }
            }
        }
        .navigationTitle(Localize.timestamps())
    }
}
