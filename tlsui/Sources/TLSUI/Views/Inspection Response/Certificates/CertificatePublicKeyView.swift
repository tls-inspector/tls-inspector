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

public struct CertificatePublicKeyView: View {
    public let certificate: Certificate

    public var body: some View {
        Section(Localize.publickey()) {
            HStack {
                Text(Localize.algorithm()).opacity(0.5)
                Spacer()
                Text(certificate.publicKey.algorithm == .rsa ? "RSA" : "ECDSA")
            }
            HStack {
                Text(Localize.signature()).opacity(0.5)
                Spacer()
                Text(certificate.signatureAlgorithm)
            }
            HStack {
                Text(Localize.keysize()).opacity(0.5)
                Spacer()
                Text(verbatim: "\(certificate.publicKey.size)")
            }
        }
    }
}
