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

public struct TrustStatusView: View {
    public let status: TrustStatus
    public let showDetailsButton: Bool
    private let backgroundColor: Color
    private let textColor: Color
    private let iconName: String
    private let text: String
    @State private var showDetails: Bool = false

    public init(status: TrustStatus, showDetailsButton: Bool = true) {
        self.status = status
        self.showDetailsButton = showDetailsButton

        switch status {
        case .trusted:
            backgroundColor = .trustColourTrusted
            textColor = .white
            iconName = "checkmark.circle.fill"
            text = "Trusted"
        case .locallyTrusted:
            backgroundColor = .trustColourLocallyTrusted
            textColor = .white
            iconName = "checkmark.circle"
            text = "Locally Trusted"
        case .untrusted, .invalidDate:
            backgroundColor = .trustColourUntrusted
            textColor = .black
            iconName = "exclamationmark.triangle"
            text = "Untrusted"
        case .wrongHost, .sha1Leaf, .sha1Intermediate, .selfSigned, .revokedLeaf, .revokedIntermediate, .weakRSAKey, .issueDateTooLong, .leafMissingRequiredKeyUsage:
            backgroundColor = .trustColourError
            textColor = .black
            iconName = "exclamationmark.triangle.fill"
            text = "Untrusted"
        case .badAuthority:
            backgroundColor = .trustColourDanger
            textColor = .white
            iconName = "exclamationmark.octagon.fill"
            text = "Dangerous & Unsafe"
        }
    }

    public var body: some View {
        HStack {
            Image(systemName: self.iconName)
                .foregroundStyle(self.textColor)
            Text(self.text)
                .font(.headline)
                .foregroundStyle(self.textColor)
            if showDetailsButton {
                Spacer()
                Button {
                    self.showDetails = true
                } label: {
                    Image(systemName: "info.circle.fill")
                }
                .foregroundStyle(self.textColor)
            }
        }
        .listRowBackground(self.backgroundColor)
        .popover(isPresented: $showDetails) {
            TrustExplainationView(status: status)
        }
    }
}
