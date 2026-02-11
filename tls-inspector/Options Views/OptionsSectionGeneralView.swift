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

private struct LanguageOption: Sendable, Hashable, Identifiable {
    let title: String
    var id: SupportedLanguages
}

private let LanguageChoices: [LanguageOption] = [
    .init(title: "English", id: .English),
    .init(title: "Nederlands", id: .Dutch),
    .init(title: "Deutsch", id: .German),
    .init(title: "Español", id: .Spanish),
]

public struct OptionsSectionGeneralView: View {
    public let rememberRecentLookups: Binding<Bool>
    public let showTips: Binding<Bool>
    public let getHttpHeaders: Binding<Bool>
    public let treatUnrecognizedAsTrusted: Binding<Bool>
    @State private var currentLanguage: LanguageOption
    @State private var showLanguageChangeAlert = false

    init(rememberRecentLookups: Binding<Bool>, showTips: Binding<Bool>, getHttpHeaders: Binding<Bool>, treatUnrecognizedAsTrusted: Binding<Bool>) {
        self.rememberRecentLookups = rememberRecentLookups
        self.showTips = showTips
        self.getHttpHeaders = getHttpHeaders
        self.treatUnrecognizedAsTrusted = treatUnrecognizedAsTrusted
        self.currentLanguage = LanguageChoices.first {
            return $0.id == UserOptions.current.appLanguage
        } ?? LanguageChoices[0]
    }

    public var body: some View {
        Section {
            Toggle(Localize.rememberrecentlookups(), isOn: rememberRecentLookups)
                .tint(.accent)
            Toggle(Localize.showtips(), isOn: showTips)
                .tint(.accent)
            Toggle(Localize.showhttpheaders(), isOn: getHttpHeaders)
                .tint(.accent)
            Toggle(Localize.treatunrecognizedastrusted(), isOn: treatUnrecognizedAsTrusted)
                .tint(.accent)
            NavigationLink(Localize.appicon()) {
                AppIconView()
            }
            Picker(Localize.applanguage(), selection: $currentLanguage) {
                ForEach(LanguageChoices) { choice in
                    Text(choice.title).tag(choice)
                }
            }
        } header: {
            Text(Localize.general())
        } footer: {
            Text("Interested in helping translate TLS Inspector? We've love to hear from you! Get in touch using the links on the About page.")
        }
        .onChange(of: currentLanguage) { newValue in
            UserOptions.current.appLanguage = newValue.id
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
