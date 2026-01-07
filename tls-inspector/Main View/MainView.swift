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

struct MainView: View {
    @State var host: String = ""
    @State var isLoading: Bool = false
    @State var inspectionResponse: InspectionResponse?
    @State var inspectionError: String?
    @State var showInspectionError = false
    @State var showAboutView = false
    @State var showOptionsView = false
    @State var showProxyWarning = false
    let randomSite = FunStuff.randomWebsite()

    var body: some View {
        Navigation {
            List {
                PreviewBuildView()
                Section(Localize.domainnameoripaddress()) {
                    TextField(text: $host) {
                        Text(self.randomSite)
                    }
                    .submitLabel(.go)
                    .onSubmit {
                        Task {
                            await self.inspectFromInput()
                        }
                    }
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .disabled(self.isLoading)
                    if isLoading {
                        HStack {
                            ProgressView()
                                .id(UUID()) // Needed to work around longstanding SwiftUI bug that Apple just keeps on ignoring...
                            Text(Localize.pleasewait())
                        }
                    }
                    if let error = self.inspectionError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                            Text(error)
                        }
                    }
                }
                RecentInspectionsView { request in
                    Task {
                        await executeInspectionRequest(request)
                    }
                }
            }
            .navigationTitle("TLS Inspector")
            .sheet(isPresented: $showAboutView, content: {
                AboutView()
            })
            .fullScreenCover(item: $inspectionResponse) { response in
                TLSUI.InspectionResponseView(response: response)
            }
            .fullScreenCover(isPresented: $showOptionsView, content: {
                OptionsView(presented: $showOptionsView)
            })
            .fullScreenCover(isPresented: $showProxyWarning, content: {
                ProxyNoticeView()
            })
            .alert(Localize.error(), isPresented: $showInspectionError, actions: {
                Button(Localize.dismiss()) {
                    showInspectionError = false
                }
            }, message: {
                Text(self.inspectionError ?? "")
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button {
                            self.showAboutView = true
                        } label: {
                            Label(Localize.about(), systemImage: "info.circle")
                        }
                        Button {
                            self.showOptionsView = true
                        } label: {
                            Label(Localize.options(), systemImage: "gearshape.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await self.inspectFromInput()
                        }
                    } label: {
                        Image(systemName: "arrow.right.circle")
                    }
                    .disabled(self.isLoading)
                }
            }
        }
    }

    func inspectFromInput() async {
        let request = InspectionRequest(address: self.host, checkCRL: UserOptions.current.checkCrl, checkOCSP: UserOptions.current.queryOcsp, ipVersion: UserOptions.current.ipVersion.toTLSKit(), checkHTTP: UserOptions.current.getHttpHeaders, timeoutSeconds: UInt8(UserOptions.current.inspectTimeout), alpn: ["http/1.1"])
        await executeInspectionRequest(request)
    }

    func executeInspectionRequest(_ request: InspectionRequest) async {
        if isProxyEnabled() {
            self.showProxyWarning = true
            return
        }

        self.isLoading = true
        let cryptoEngine = UserOptions.current.cryptoEngine.toTLSKit()
        let session = InspectionSession(engineType: cryptoEngine)
        let telemetry = Telemetry()
        do {
            let result = try await session.execute(request)
            self.inspectionResponse = result
            self.inspectionError = nil
            self.isLoading = false
            InspectionHistoryManager.shared.add(request)
            DispatchQueue.global(qos: .background).async {
                telemetry.inspectionRequestSuccess(engineType: cryptoEngine, request: request, elapsed: result.elapsedNs)
            }
        } catch {
            DispatchQueue.global(qos: .background).async {
                telemetry.inspectionRequestFailed(engineType: cryptoEngine, request: request, error: error)
            }
            self.inspectionError = error.localizedDescription
            self.isLoading = false
            self.showInspectionError = true
        }
    }
}
