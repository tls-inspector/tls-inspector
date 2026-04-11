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

public struct OptionsSectionGeneralView: View {
    @EnvironmentObject private var userOptions: UserOptions
    @State private var showLanguageChangeAlert = false

    public var body: some View {
        Section {
            Toggle(Localize.rememberrecentlookups(), isOn: $userOptions.rememberRecentLookups)
                .tint(.accent)
            Toggle(Localize.showhttpheaders(), isOn: $userOptions.getHttpHeaders)
                .tint(.accent)
            Toggle(Localize.treatunrecognizedastrusted(), isOn: $userOptions.treatUnrecognizedAsTrusted)
                .tint(.accent)
            NavigationLink(Localize.appicon()) {
                AppIconView()
            }
            Picker(Localize.applanguage(), selection: $userOptions.appLanguage) {
                ForEach(SupportedLanguages.allCases) { lang in
                    Text(String(describing: lang)).tag(lang)
                }
            }
        } header: {
            Text(Localize.general())
        } footer: {
            Text("Interested in helping translate TLS Inspector? We've love to hear from you! Get in touch using the links on the About page.")
        }
        .onChange(of: userOptions.appLanguage) { newValue in
            currentLanguage = newValue
            self.showLanguageChangeAlert = true
        }
        .alert(Localize.languageupdated(), isPresented: $showLanguageChangeAlert) {
            Button(Localize.dismiss()) {
                self.showLanguageChangeAlert = false
            }
        } message: {
            Text(Localize.youmustrestarttheappforthechangetotakeeffect())
        }
    }
}
