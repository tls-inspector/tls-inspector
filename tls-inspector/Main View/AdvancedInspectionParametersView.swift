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
import TLSUI
import Localization

internal struct AdvancedInspectionParametersView: View {
    private let parameters: Binding<InspectionParameters>

    public init(parameters: Binding<InspectionParameters>) {
        self.parameters = parameters
    }

    public var body: some View {
        Group {
            TextField(Localize.ipaddress(), text: parameters.ipAddress)
            Picker(selection: parameters.useIpVersion) {
                Text(Localize.auto()).tag(IPVersion.Automatic)
                Text("IPv4").tag(IPVersion.IPv4)
                Text("IPv6").tag(IPVersion.IPv6)
            } label: {
                Text(Localize.useipversion())
            }
        }
    }
}
