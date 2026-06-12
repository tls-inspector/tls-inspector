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

public struct CertificateFingerprintView: View {
    public let certificate: Certificate

    public var body: some View {
        Section(Localize.fingerprints()) {
            if UserOptions().showFingerprintMd5, let md5 = try? certificate.fingerprint(.md5) {
                TitleValueView(title: "MD5") {
                    Text(md5.hexEncodedString())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            }
            if UserOptions().showFingerprintSha1, let sha1 = try? certificate.fingerprint(.sha1) {
                TitleValueView(title: "SHA1") {
                    Text(sha1.hexEncodedString())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            }
            if UserOptions().showFingerprintSha256, let sha256 = try? certificate.fingerprint(.sha256) {
                TitleValueView(title: "SHA-256") {
                    Text(sha256.hexEncodedString())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            }
            if UserOptions().showFingerprintSha512, let sha512 = try? certificate.fingerprint(.sha512) {
                TitleValueView(title: "SHA-512") {
                    Text(sha512.hexEncodedString())
                        .fixedwidth()
                        .textSelection(.enabled)
                }
            }
        }
    }
}
