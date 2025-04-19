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

struct MainView: View {
    @State var host: String = ""
    @State var isLoading: Bool = false
    @State var inspectionResponse: InspectionResponse?
    @State var inspectionError: String?
    @State var showInspectionError = false
    @State var showAboutView = false
    @State var showOptionsView = false
    @State var showProxyWarning = false

    var body: some View {
        NavigationStack {
            List {
                Section(Localize.domainnameoripaddress()) {
                    TextField(text: $host) {
                        Text("google.com")
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
                InspectionResponseView(response: response)
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
        let request = InspectionRequest(address: self.host)
        await executeInspectionRequest(request)
    }

    func executeInspectionRequest(_ request: InspectionRequest) async {
        if isProxyEnabled() {
            self.showProxyWarning = true
            return
        }

        self.isLoading = true
        let session = InspectionSession(engineType: .NetworkFramework)
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
