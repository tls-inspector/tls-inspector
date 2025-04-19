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

public struct CertificateKeyIdentifiersView: View {
    public let certificate: Certificate

    public var body: some View {
        Section(Localize.keyidentifiers()) {
            if let subject = certificate.subjectKeyId {
                TitleValueView(title: Localize.subject()) {
                    Text(subject.hexEncodedString())
                        .monospaced()
                        .textSelection(.enabled)
                }
            }
            if let authority = certificate.authorityKeyId {
                TitleValueView(title: Localize.authority()) {
                    Text(authority.hexEncodedString())
                        .monospaced()
                        .textSelection(.enabled)
                }
            }
        }
    }
}
