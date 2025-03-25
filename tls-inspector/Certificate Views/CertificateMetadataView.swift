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
        Section(Localize.metadata()) {
            TitleValueView(title: Localize.serialnumber()) {
                Text(certificate.serial.hexEncodedString()).monospaced()
            }
            if let source = certificate.source {
                HStack {
                    Text("Certificate Source").opacity(0.5)
                    Spacer()
                    switch source {
                    case .server:
                        Text("Sent by server")
                    case .localStore:
                        Text("Present on device")
                    }
                }
            }
            HStack {
                Text(Localize.certificateauthority()).opacity(0.5)
                Spacer()
                Text(certificate.isCA ? Localize.yes() : Localize.no())
            }
            HStack {
                Text(Localize.version()).opacity(0.5)
                Spacer()
                Text(verbatim: "\(certificate.version)")
            }
            if let timestamps = certificate.signedTimestamps {
                NavigationLink {
                    CertificateTimestampView(timestamps: timestamps)
                } label: {
                    Text(Localize.certificatetimestamps())
                    Spacer()
                    Text(verbatim: "\(timestamps.count)").opacity(0.5)
                }
            }
        }
    }
}
