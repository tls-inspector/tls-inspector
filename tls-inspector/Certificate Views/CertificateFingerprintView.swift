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

public struct CertificateFingerprintView: View {
    public let certificate: Certificate

    public var body: some View {
        Section(Localize.fingerprints()) {
            if let md5 = try? certificate.fingerprint(.md5) {
                HStack {
                    Text("MD5").opacity(0.5)
                    Spacer()
                    Text(md5.hexEncodedString())
                        .monospaced()
                }
            }
            if let sha1 = try? certificate.fingerprint(.sha1) {
                HStack {
                    Text("SHA1").opacity(0.5)
                    Spacer()
                    Text(sha1.hexEncodedString())
                        .monospaced()
                }
            }
            if let sha256 = try? certificate.fingerprint(.sha256) {
                HStack {
                    Text("SHA-256").opacity(0.5)
                    Spacer()
                    Text(sha256.hexEncodedString())
                        .monospaced()
                }
            }
            if let sha512 = try? certificate.fingerprint(.sha512) {
                HStack {
                    Text("SHA-512").opacity(0.5)
                    Spacer()
                    Text(sha512.hexEncodedString())
                        .monospaced()
                }
            }
        }
    }
}
