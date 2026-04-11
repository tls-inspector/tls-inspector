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

public struct AdvancedOptionsView: View {
    @EnvironmentObject private var userOptions: UserOptions
    @State private var showNag = false
    @State private var showRootCaCertificateView = false
    @State private var didReset = false
    @State private var didTruncate = false

    public var body: some View {
        List {
            Section {
                Picker(Localize.networkengine(), selection: $userOptions.cryptoEngine) {
                    Text("Apple").tag(CryptoEngine.NetworkFramework)
                    Text("OpenSSL").tag(CryptoEngine.OpenSSL)
                }
                if UserOptions().cryptoEngine == .OpenSSL {
                    VStack(alignment: .leading) {
                        Text(Localize.allowedciphers()).bold()
                        TextField(Localize.allowedciphers(), text: $userOptions.preferredCiphers)
                            .keyboardType(.asciiCapable)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .font(Font.custom("Menlo", size: 16, relativeTo: .body))
                    }
                }
            } header: {
                Text(Localize.engineoptions())
            } footer: {
                Text(Localize.networkenginefooter())
            }
            Section(Localize.networkoptions()) {
                Picker(Localize.useipversion(), selection: $userOptions.ipVersion) {
                    Text(Localize.auto()).tag(IPVersion.Automatic)
                    Text("IPv4").tag(IPVersion.IPv4)
                    Text("IPv6").tag(IPVersion.IPv6)
                }
                HStack {
                    Text(Localize.timeout())
                    TextField(Localize.timeout(), value: $userOptions.inspectTimeout, format: .number)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.trailing)
                    Text(Localize.seconds()).opacity(0.5)
                }
            }
            Section {
                Toggle(Localize.verboselogging(), isOn: $userOptions.verboseLogging)
                    .tint(.accent)
                ExportFileView(fileUrl: LogWriter.shared.filePath) {
                    HStack {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.red)
                        Text(Localize.exportlogs())
                    }
                }
                ListButton {
                    do {
                        try LogWriter.shared.truncate()
                        self.didTruncate = true
                    } catch {
                        //
                    }
                } label: {
                    Text("Empty log file")
                        .foregroundStyle(.red)
                }
                .disabled(self.didTruncate)
            } header: {
                Text(Localize.loggingsupport())
            } footer: {
                Text(Localize.loggingfooter())
            }
            Section {
                ListButton {
                    showRootCaCertificateView = true
                } label: {
                    Text(Localize.rootcacertificates())
                }
            }
            Section {
                ListButton {
                    UserOptions.reset()
                    self.didReset = true
                } label: {
                    Text(Localize.resettodefaultsettings())
                        .foregroundStyle(.red)
                }
                .disabled(self.didReset)
            }
        }
        .navigationTitle(Localize.advancedoptions())
        .alert(Localize.advancedoptions(), isPresented: $showNag, actions: {
            Button(Localize.dismiss()) {
                self.showNag = false
                userOptions.advancedSettingsNagDismissed = true
            }
        }, message: {
            Text(Localize.advancedsettingsnag())
        })
        .task {
            if !userOptions.advancedSettingsNagDismissed {
                showNag = true
            }
        }
        .fullScreenCover(isPresented: $showRootCaCertificateView) {
            RootCACertificatesView(isPresented: $showRootCaCertificateView)
        }
    }
}
