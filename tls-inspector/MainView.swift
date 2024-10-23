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

struct MainView: View {
    @State var host: String = ""
    @State var isLoading: Bool = false
    @State var inspectionResponse: InspectionResponse?
    @State var inspectionError: String?
    @State var showInspectionError = false

    var body: some View {
        NavigationStack {
            List {
                Section("Domain Name or IP Address") {
                    TextField(text: $host) {
                        Text("google.com")
                    }
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .disabled(self.isLoading)
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Please wait...")
                        }
                    }
                    if let error = self.inspectionError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text(error)
                        }
                    }
                }
            }
            .navigationTitle("TLS Inspector")
            .fullScreenCover(item: $inspectionResponse) { response in
                InspectionResponseView(response: response)
            }
            .alert("Error", isPresented: $showInspectionError, actions: {
                Button("Dismiss") {
                    showInspectionError = false
                }
            }, message: {
                Text(self.inspectionError ?? "")
            })
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await self.performInspection()
                        }
                    } label: {
                        Image(systemName: "arrow.right.circle")
                    }
                    .disabled(self.isLoading)
                }
            }
        }
    }

    func performInspection() async {
        self.isLoading = true
        let request = InspectionRequest(address: self.host)
        let session = InspectionSession(engineType: .NetworkFramework)
        do {
            let result = try await session.execute(request)
            self.inspectionResponse = result
            self.isLoading = false
        } catch {
            self.inspectionError = error.localizedDescription
            self.isLoading = false
            self.showInspectionError = true
        }
    }
}
