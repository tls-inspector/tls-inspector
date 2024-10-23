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

public struct CertificateMetadataView: View {
    public let certificate: Certificate

    public var body: some View {
        Section("Metadata") {
            TitleValueView(title: "Serial Number") {
                Text(certificate.serial.hexEncodedString()).monospaced()
            }
            HStack {
                Text("Certificate Authority").opacity(0.5)
                Spacer()
                Text(certificate.isCA ? "Yes" : "No")
            }
            HStack {
                Text("Version").opacity(0.5)
                Spacer()
                Text(verbatim: "\(certificate.version)")
            }
            if let timestamps = certificate.signedTimestamps {
                NavigationLink {
                    CertificateTimestampView(timestamps: timestamps)
                } label: {
                    Text("Certificate Timestamps")
                    Spacer()
                    Text(verbatim: "\(timestamps.count)").opacity(0.5)
                }
            }
        }
    }
}
