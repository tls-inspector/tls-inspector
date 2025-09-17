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
                OptionsSectionGeneralView(rememberRecentLookups: $rememberRecentLookups, showTips: $showTips, getHttpHeaders: $getHttpHeaders, treatUnrecognizedAsTrusted: $treatUnrecognizedAsTrusted)
                OptionsSectionCertificateStatus(queryOcsp: $queryOcsp, checkCrl: $checkCrl)
                OptionsSectionFingerprintsView(showFingerprintMd5: $showFingerprintMd5, showFingerprintSha1: $showFingerprintSha1, showFingerprintSha256: $showFingerprintSha256, showFingerprintSha512: $showFingerprintSha512)
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
            .onChange(of: rememberRecentLookups) {
                UserOptions.current.rememberRecentLookups = $0
            }
            .onChange(of: showTips) {
                UserOptions.current.showTips = $0
            }
            .onChange(of: getHttpHeaders) {
                UserOptions.current.getHttpHeaders = $0
            }
            .onChange(of: treatUnrecognizedAsTrusted) {
                UserOptions.current.treatUnrecognizedAsTrusted = $0
            }
            .onChange(of: queryOcsp) {
                UserOptions.current.queryOcsp = $0
            }
            .onChange(of: checkCrl) {
                UserOptions.current.checkCrl = $0
            }
            .onChange(of: showFingerprintMd5) {
                UserOptions.current.showFingerprintMd5 = $0
            }
            .onChange(of: showFingerprintSha1) {
                UserOptions.current.showFingerprintSha1 = $0
            }
            .onChange(of: showFingerprintSha256) {
                UserOptions.current.showFingerprintSha256 = $0
            }
            .onChange(of: showFingerprintSha512) {
                UserOptions.current.showFingerprintSha512 = $0
            }
        }
    }
}
