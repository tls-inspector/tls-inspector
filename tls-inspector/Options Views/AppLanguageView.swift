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
import TLSUI
import Localization

struct AppLanguageView: View {
    @EnvironmentObject private var userOptions: UserOptions
    @State private var showRestartAlert = false

    var body: some View {
        List {
            Section {
                Toggle(isOn: $userOptions.useSystemLanguage) {
                    Text(Localize.usesystemlanguage())
                }
                .tint(.accent)
            }
            Section {
                ForEach(SupportedLanguages.allCases, id:\.rawValue) { language in
                    Button {
                        userOptions.languageOverride = language
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(String.init(describing: language))
                                Text(Localize.percentcomplete(percent: "\(language.percentTranslated)")).font(.caption)
                            }
                            Spacer()
                            if userOptions.languageOverride == language {
                                Image(systemName: "checkmark").foregroundStyle(.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(userOptions.useSystemLanguage)
                }
            } footer: {
                // This is intentionally not localized
                Text("• Spanish translation by Kevin López Brante\n• German translation by David Czihak\n• Dutch translation by Erik van Straten\n• Polish translation by Github user @marcinmajsc\n• French translation by Github user @nmhuy\n\nInterested in helping translate TLS Inspector? We've love to hear from you! Get in touch using the links on the About page.")
            }
        }
        .navigationTitle(Localize.applanguage())
        .onChange(of: userOptions.useSystemLanguage) { _ in
            showRestartAlert = true
        }
        .onChange(of: userOptions.languageOverride) { _ in
            showRestartAlert = true
        }
        .alert(Localize.applanguage(), isPresented: $showRestartAlert) {
            Button {
                showRestartAlert = false
            } label: {
                Text(Localize.dismiss())
            }
        } message: {
            Text(Localize.youmustrestarttheappforthechangetotakeeffect())
        }

    }
}

#Preview {
    AppLanguageView()
}
