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

struct DomainInput: View {
    let host: Binding<String>
    let showAdvancedInspectionOptions: Binding<Bool>
    let isLoading: Binding<Bool>
    let onSubmit: () -> Void
    private let randomSite = FunStuff.randomWebsite()

    var body: some View {
        TextField(text: host) {
            if showAdvancedInspectionOptions.wrappedValue {
                Text(Localize.domainnameoripaddress())
            } else {
                Text(self.randomSite)
            }
        }
        .submitLabel(.go)
        .onSubmit {
            onSubmit()
        }
        .keyboardType(.URL)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .disabled(isLoading.wrappedValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading, 20)
    }
}
