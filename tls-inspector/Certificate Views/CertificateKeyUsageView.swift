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

public struct CertificateKeyUsageView: View {
    public let keyUsage: KeyUsage

    public var body: some View {
        Section(Localize.keyusage()) {
            if let basic = keyUsage.basic {
                TitleValueView(title: Localize.basic()) {
                    Text(basic.map({ ku in
                        return ku.rawValue
                    }).joined(separator: ", "))
                }
            }
            if let extended = keyUsage.extended {
                TitleValueView(title: Localize.extended()) {
                    Text(extended.map({ ku in
                        return ku.rawValue
                    }).joined(separator: ", "))
                }
            }
        }
    }
}
