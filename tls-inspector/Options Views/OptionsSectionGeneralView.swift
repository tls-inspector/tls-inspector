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

public struct OptionsSectionGeneralView: View {
    public let rememberRecentLookups: Binding<Bool>
    public let showTips: Binding<Bool>
    public let getHttpHeaders: Binding<Bool>
    public let treatUnrecognizedAsTrusted: Binding<Bool>

    public var body: some View {
        Section(Localize.general()) {
            Toggle(Localize.rememberrecentlookups(), isOn: rememberRecentLookups)
                .tint(.accent)
            Toggle(Localize.showtips(), isOn: showTips)
                .tint(.accent)
            Toggle(Localize.httpheaders(), isOn: getHttpHeaders)
                .tint(.accent)
            Toggle(Localize.treatunrecognizedastrusted(), isOn: treatUnrecognizedAsTrusted)
                .tint(.accent)
            NavigationLink(Localize.appicon()) {
                AppIconView()
            }
        }
    }
}
