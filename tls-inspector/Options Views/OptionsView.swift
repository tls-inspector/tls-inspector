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

public struct OptionsView: View {
    public let presented: Binding<Bool>
    @State private var rememberRecentLookups = UserOptions.current.rememberRecentLookups
    @State private var showTips = UserOptions.current.showTips
    @State private var getHttpHeaders = UserOptions.current.getHttpHeaders
    @State private var treatUnrecognizedAsTrusted = UserOptions.current.treatUnrecognizedAsTrusted
    @State private var queryOcsp = UserOptions.current.queryOcsp
    @State private var checkCrl = UserOptions.current.checkCrl
    @State private var showFingerprintMd5 = UserOptions.current.showFingerprintMd5
    @State private var showFingerprintSha1 = UserOptions.current.showFingerprintSha1
    @State private var showFingerprintSha256 = UserOptions.current.showFingerprintSha256
    @State private var showFingerprintSha512 = UserOptions.current.showFingerprintSha512

    public var body: some View {
        Navigation {
            List {
                Section(Localize.general()) {
                    Toggle(Localize.rememberrecentlookups(), isOn: $rememberRecentLookups)
                        .tint(.accent)
                    Toggle(Localize.showtips(), isOn: $showTips)
                        .tint(.accent)
                    Toggle(Localize.httpheaders(), isOn: $getHttpHeaders)
                        .tint(.accent)
                    Toggle(Localize.treatunrecognizedastrusted(), isOn: $treatUnrecognizedAsTrusted)
                        .tint(.accent)
                    NavigationLink(Localize.appicon()) {
                        AppIconView()
                    }
                }
                Section {
                    Toggle(Localize.queryocspresponder(), isOn: $queryOcsp)
                        .tint(.accent)
                    Toggle(Localize.downloadcheckcrl(), isOn: $checkCrl)
                        .tint(.accent)
                } header: {
                    Text(Localize.certificatestatus())
                } footer: {
                    Text(Localize.certificatestatusfooter())
                }
                Section(Localize.fingerprints()) {
                    Toggle("MD5", isOn: $showFingerprintMd5)
                        .tint(.accent)
                    Toggle("SHA-1", isOn: $showFingerprintSha1)
                        .tint(.accent)
                    Toggle("SHA-256", isOn: $showFingerprintSha256)
                        .tint(.accent)
                    Toggle("SHA-512", isOn: $showFingerprintSha512)
                        .tint(.accent)
                }
                Section {
                    NavigationLink(Localize.advancedoptions()) {
                        AdvancedOptionsView()
                    }
                }
            }
            .navigationTitle(Localize.options())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.presented.wrappedValue = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onChange(of: rememberRecentLookups, { _, newValue in
                UserOptions.current.rememberRecentLookups = newValue
            })
            .onChange(of: showTips, { _, newValue in
                UserOptions.current.showTips = newValue
            })
            .onChange(of: getHttpHeaders, { _, newValue in
                UserOptions.current.getHttpHeaders = newValue
            })
            .onChange(of: treatUnrecognizedAsTrusted, { _, newValue in
                UserOptions.current.treatUnrecognizedAsTrusted = newValue
            })
            .onChange(of: queryOcsp, { _, newValue in
                UserOptions.current.queryOcsp = newValue
            })
            .onChange(of: checkCrl, { _, newValue in
                UserOptions.current.checkCrl = newValue
            })
            .onChange(of: showFingerprintMd5, { _, newValue in
                UserOptions.current.showFingerprintMd5 = newValue
            })
            .onChange(of: showFingerprintSha1, { _, newValue in
                UserOptions.current.showFingerprintSha1 = newValue
            })
            .onChange(of: showFingerprintSha256, { _, newValue in
                UserOptions.current.showFingerprintSha256 = newValue
            })
            .onChange(of: showFingerprintSha512, { _, newValue in
                UserOptions.current.showFingerprintSha512 = newValue
            })
        }
    }
}
