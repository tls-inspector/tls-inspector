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

internal class InspectionParameters: ObservableObject {
    @Published var host = ""
    @Published var ipAddress = ""
    @Published var port: UInt16 = 443
    @Published var useIpVersion = IPVersion.Automatic
}

struct MainView: View {
    @StateObject var inspectionParameters = InspectionParameters()
    @State var isLoading: Bool = false
    @State var inspectionResponse: InspectionResponse?
    @State var inspectionError: String?
    @State var showInspectionError = false
    @State var showAboutView = false
    @State var showOptionsView = false
    @State var showProxyWarning = false
    @State var showAdvancedInspectionOptions = false

    var body: some View {
        Navigation {
            List {
                PreviewBuildView()
                Section(showAdvancedInspectionOptions ? Localize.target() : Localize.domainnameoripaddress()) {
                    HStack {
                        DomainInput(host: $inspectionParameters.host, showAdvancedInspectionOptions: $showAdvancedInspectionOptions, isLoading: $isLoading) {
                            Task {
                                await self.inspectFromInput()
                            }
                        }
                        Button {
                            withAnimation {
                                self.showAdvancedInspectionOptions.toggle()
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .tint(.accent)
                                .padding(.vertical, 11)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowInsets(EdgeInsets())
                    if showAdvancedInspectionOptions {
                        AdvancedInspectionParametersView(ipAddress: $inspectionParameters.ipAddress, useIpVersion: $inspectionParameters.useIpVersion)
                    }
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
                            Label(Localize.about(), systemImage: "info")
                        }
                        Button {
                            self.showOptionsView = true
                        } label: {
                            Label(Localize.options(), systemImage: "gearshape.fill")
                        }
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "ellipsis")
                        } else {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await self.inspectFromInput()
                        }
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "arrow.right")
                        } else {
                            Image(systemName: "arrow.right.circle")
                        }
                    }
                    .disabled(self.isLoading)
                }
            }
        }
    }

    func inspectFromInput() async {
        let address = inspectionParameters.ipAddress.isEmpty ? inspectionParameters.host : inspectionParameters.ipAddress
        let serverName = inspectionParameters.ipAddress.isEmpty ? nil : inspectionParameters.host

        let request = InspectionRequest(
            address: address,
            serverName: serverName,
            checkCRL: UserOptions().checkCrl,
            checkOCSP: UserOptions().queryOcsp,
            ipVersion: inspectionParameters.useIpVersion.toTLSKit(),
            checkHTTP: UserOptions().getHttpHeaders,
            timeoutSeconds: UInt8(UserOptions().inspectTimeout),
            alpn: ["http/1.1"]
        )
        await executeInspectionRequest(request)
    }

    func executeInspectionRequest(_ request: InspectionRequest) async {
        if isProxyEnabled() {
            self.showProxyWarning = true
            return
        }

        self.isLoading = true
        let cryptoEngine = UserOptions().cryptoEngine.toTLSKit()
        let session = InspectionSession(engineType: cryptoEngine)
        do {
            let result = try await session.execute(request)
            self.inspectionResponse = result
            self.inspectionError = nil
            self.isLoading = false
            InspectionHistoryManager.shared.add(request)
        } catch {
            self.inspectionError = error.localizedDescription
            self.isLoading = false
            self.showInspectionError = true
        }
    }
}
