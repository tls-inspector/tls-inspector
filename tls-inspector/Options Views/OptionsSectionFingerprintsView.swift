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

public struct OptionsSectionFingerprintsView: View {
    public let showFingerprintMd5: Binding<Bool>
    public let showFingerprintSha1: Binding<Bool>
    public let showFingerprintSha256: Binding<Bool>
    public let showFingerprintSha512: Binding<Bool>

    public var body: some View {
        Section(Localize.fingerprints()) {
            Toggle("MD5", isOn: showFingerprintMd5)
                .tint(.accent)
            Toggle("SHA-1", isOn: showFingerprintSha1)
                .tint(.accent)
            Toggle("SHA-256", isOn: showFingerprintSha256)
                .tint(.accent)
            Toggle("SHA-512", isOn: showFingerprintSha512)
                .tint(.accent)
        }
    }
}
