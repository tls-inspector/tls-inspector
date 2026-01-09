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

struct PreviewBuildView: View {
    @State private var showPreviewDetails = false

    var body: some View {
        HStack {
            Image(systemName: "airplane.circle.fill")
                .foregroundStyle(.black)
            Text("Preview Build")
                .font(.headline)
                .foregroundStyle(.black)
            Spacer()
            Button {
                self.showPreviewDetails = true
            } label: {
                Image(systemName: "info.circle.fill")
            }
            .foregroundStyle(.black)
        }
        .listRowBackground(IRoundedRectangle(backgroundColor: .yellow, borderColor: .clear, borderWidth: 0))
        .alert("Preview Build", isPresented: $showPreviewDetails) {
            Link(destination: URL(string: "https://tlsinspector.com/privacy_testflight.html")!) {
                Text("Privacy Policy")
            }
            Button("Dismiss") {
                showPreviewDetails = false
            }
        } message: {
            Text("This build of TLS Inspector is a preview of a upcoming release of the app.\n\nPreview builds are time-limited and you will eventually be required to return to the App Store release of the app.\n\nPreview builds contain telemetry to better understand how the app performs and to catch any unexpected errors.\n\nYou may opt-out of the preview build by uninstalling the app and re-installing the app from the App Store.")
        }
    }
}
