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

public struct TrustExplainationView: View {
    public let status: TrustStatus
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                TrustStatusView(status: status, showDetailsButton: false)
                Section(Localize.whatdoesthismean()) {
                    switch status {
                    case .trusted:
                        Text(Localize.whatdoesthismeantrusted())
                    case .locallyTrusted:
                        Text(Localize.whatdoesthismeanlocallytrusted())
                    case .untrusted:
                        Text(Localize.whatdoesthismeanuntrusted())
                    case .invalidDate:
                        Text(Localize.whatdoesthismeaninvaliddate())
                    case .wrongHost:
                        Text(Localize.whatdoesthismeanwronghost())
                    case .sha1Leaf:
                        Text(Localize.whatdoesthismeansha1leaf())
                    case .sha1Intermediate:
                        Text(Localize.whatdoesthismeansha1intermediate())
                    case .selfSigned:
                        Text(Localize.whatdoesthismeanselfsigned())
                    case .revokedLeaf:
                        Text(Localize.whatdoesthismeanrevokedleaf())
                    case .revokedIntermediate:
                        Text(Localize.whatdoesthismeanrevokedintermediate())
                    case .weakRSAKey:
                        Text(Localize.whatdoesthismeanweakrsakey())
                    case .issueDateTooLong:
                        Text(Localize.whatdoesthismeanissuedatetoolong())
                    case .leafMissingRequiredKeyUsage:
                        Text(Localize.whatdoesthismeanleafmissingrequiredkeyusage())
                    case .unknownCriticalExtension:
                        Text(Localize.whatdoesthismeanunknowncriticalextension())
                    case .badAuthority:
                        Text(Localize.whatdoesthismeanbadauthority())
                    }
                }
                if status == .locallyTrusted {
                    SafetyWarningView(title: Localize.danger(), message: Localize.guidancewarning())
                        .listRowBackground(RoundedRectangle(cornerRadius: 10).fill(.clear).strokeBorder(Color.red, lineWidth: 2))
                }
            }
            .navigationTitle(Localize.trustdetails())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
