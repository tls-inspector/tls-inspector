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
    @State private var showNag = false
    @State private var networkEngine = UserOptions.current.cryptoEngine
    @State private var preferredCiphers = UserOptions.current.preferredCiphers
    @State private var ipVersion = UserOptions.current.ipVersion
    @State private var inspectTimeout = UserOptions.current.inspectTimeout
    @State private var verboseLogging = UserOptions.current.verboseLogging
    @State private var showRootCaCertificateView = false

    public var body: some View {
        List {
            Section {
                Picker(Localize.networkengine(), selection: $networkEngine) {
                    Text("Apple").tag(CryptoEngine.NetworkFramework)
                    Text("OpenSSL").tag(CryptoEngine.OpenSSL)
                }
                if networkEngine == .OpenSSL {
                    VStack(alignment: .leading) {
                        Text(Localize.allowedciphers()).bold()
                        TextField(Localize.allowedciphers(), text: $preferredCiphers)
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
                Picker(Localize.useipversion(), selection: $ipVersion) {
                    Text(Localize.auto()).tag(IPVersion.Automatic)
                    Text("IPv4").tag(IPVersion.IPv4)
                    Text("IPv6").tag(IPVersion.IPv6)
                }
                HStack {
                    Text(Localize.timeout())
                    TextField(Localize.timeout(), value: $inspectTimeout, format: .number)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.trailing)
                    Text(Localize.seconds()).opacity(0.5)
                }
            }
            Section {
                Toggle(Localize.verboselogging(), isOn: $verboseLogging)
                ExportFileView(fileUrl: LogWriter.shared.filePath) {
                    HStack {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.red)
                        Text(Localize.exportlogs())
                    }
                }
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
                    //
                } label: {
                    Text(Localize.resettodefaultsettings())
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(Localize.advancedoptions())
        .alert(Localize.advancedoptions(), isPresented: $showNag, actions: {
            Button(Localize.dismiss()) {
                self.showNag = false
                UserOptions.current.advancedSettingsNagDismissed = true
            }
        }, message: {
            Text(Localize.advancedsettingsnag())
        })
        .task {
            if UserOptions.current.advancedSettingsNagDismissed == false {
                showNag = true
            }
        }
        .onChange(of: networkEngine) { newValue in
            UserOptions.current.cryptoEngine = newValue
        }
        .onChange(of: preferredCiphers) { newValue in
            UserOptions.current.preferredCiphers = newValue
        }
        .onChange(of: ipVersion) { newValue in
            UserOptions.current.ipVersion = newValue
        }
        .onChange(of: inspectTimeout) { newValue in
            UserOptions.current.inspectTimeout = newValue
        }
        .fullScreenCover(isPresented: $showRootCaCertificateView) {
            RootCACertificatesView(isPresented: $showRootCaCertificateView)
        }
    }
}
