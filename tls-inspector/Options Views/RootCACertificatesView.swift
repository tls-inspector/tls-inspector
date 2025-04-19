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

public struct RootCACertificatesView: View {
    public let isPresented: Binding<Bool>
    @State private var isLoading = true
    @State private var loadError: Error?
    @State private var isUpdating = false
    @State private var updateResult: AnchorBundleUpdateResult?
    @State private var showUpdateResult = false

    public var body: some View {
        Navigation {
            List {
                if isLoading {
                    ProgressView().task {
                        loadBundles()
                    }
                } else if let loadError = self.loadError {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                            Text(Localize.error()).bold()
                        }
                        Text(loadError.localizedDescription)
                    }
                } else {
                    VStack(alignment: .center) {
                        Text(Localize.rootcabundleabout()).padding()
                    }
                    if let apple = AnchorBundleManager.shared.appleBundle {
                        AnchorBundleView(title: "Apple", bundle: apple)
                    }
                    if let google = AnchorBundleManager.shared.googleBundle {
                        AnchorBundleView(title: "Google", bundle: google)
                    }
                    if let microsoft = AnchorBundleManager.shared.microsoftBundle {
                        AnchorBundleView(title: "Microsoft", bundle: microsoft)
                    }
                    if let mozilla = AnchorBundleManager.shared.mozillaBundle {
                        AnchorBundleView(title: "Mozilla", bundle: mozilla)
                    }
                    if let tlsinspector = AnchorBundleManager.shared.tlsinspectorBundle {
                        AnchorBundleView(title: "TLS Inspector", bundle: tlsinspector)
                    }
                    Button {
                        Task {
                            isUpdating = true
                            await checkForUpdates()
                        }
                    } label: {
                        Label(Localize.checkforupdates(), systemImage: "arrow.clockwise.square.fill")
                    }
                }
            }
            .overlay {
                Group {
                    if isUpdating {
                        VStack(alignment: .center) {
                            ProgressView().controlSize(.large)
                            Text(Localize.pleasewait())
                        }
                        .padding()
                        .background(.black.opacity(0.5))
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
            }
            .navigationTitle(Localize.rootcacertificates())
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(Localize.done()) {
                        isPresented.wrappedValue = false
                    }
                    .bold()
                    .disabled(isUpdating)
                }
            }
            .alert(Localize.rootcacertificates(), isPresented: $showUpdateResult, presenting: updateResult) { _ in
                Button(Localize.dismiss()) {
                    showUpdateResult = false
                    updateResult = nil
                }
            } message: { result in
                switch result {
                case .isLatest:
                    Text("Is latest")
                case .updated:
                    Text("Updated")
                }
            }
        }
    }

    func loadBundles() {
        Task {
            defer {
                self.isLoading = false
            }
            do {
                try AnchorBundleManager.shared.loadBundles()
            } catch {
                self.loadError = error
            }
        }
    }

    func checkForUpdates() async {
        defer {
            self.isUpdating = false
        }
        do {
            let result = try await AnchorBundleManager.shared.updateNow()
            self.updateResult = result
            self.showUpdateResult = true
        } catch {
            self.updateResult = .isLatest
            self.showUpdateResult = true
        }
    }
}

private struct AnchorBundleView: View {
    public let title: String
    public let bundle: CertificateBundle

    public var body: some View {
        Section(title) {
            HStack {
                Text(Localize.bundledate()).bold()
                Spacer()
                Text(bundle.metadata.date.utcFormatted())
            }
            HStack {
                Text(Localize.certificates()).bold()
                Spacer()
                Text("\(bundle.metadata.certificateCount)")
            }
            HStack {
                Text(Localize.source()).bold()
                Spacer()
                if bundle.embedded() {
                    HStack {
                        Image(systemName: "shippingbox.fill")
                        Text(Localize.embedded())
                    }
                } else {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text(Localize.downloaded())
                    }
                }
            }
            NavigationLink {
                Text(bundle.metadata.sha256)
                    .textSelection(.enabled)
                    .lineLimit(nil)
                    .navigationTitle("SHA-256")
            } label: {
                HStack {
                    Text(Localize.signature()).bold()
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text(Localize.verified())
                    }
                }
            }
        }
    }
}
