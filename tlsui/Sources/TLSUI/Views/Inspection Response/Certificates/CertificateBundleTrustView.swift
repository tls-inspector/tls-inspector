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

public struct CertificateBundleTrustView: View {
    public let foundInBundles: [BundleProvider: Bool]

    public var body: some View {
        Section(Localize.certificatetrust()) {
            ProviderView(foundInBundles: self.foundInBundles, provider: .apple)
            ProviderView(foundInBundles: self.foundInBundles, provider: .google)
            ProviderView(foundInBundles: self.foundInBundles, provider: .microsoft)
            ProviderView(foundInBundles: self.foundInBundles, provider: .mozilla)
        }
    }
}

public struct ProviderView: View {
    public let foundInBundles: [BundleProvider: Bool]
    public let provider: BundleProvider

    public var body: some View {
        HStack {
            if self.foundInBundles[self.provider] ?? false {
                Image(systemName: "checkmark.circle").foregroundStyle(.green)
                Text(self.providerName())
            } else {
                Image(systemName: "questionmark.circle").foregroundStyle(.orange)
                VStack(alignment: .leading) {
                    Text(self.providerName())
                    Text(Localize.certificatenottrusted()).font(.footnote)
                }
            }
        }
    }

    func providerName() -> String {
        switch provider {
        case .apple:
            return Localize.apple()
        case .google:
            return Localize.google()
        case .microsoft:
            return Localize.microsoft()
        case .mozilla:
            return Localize.mozilla()
        case .tlsInspector:
            return Localize.tlsinspector()
        }
    }
}
