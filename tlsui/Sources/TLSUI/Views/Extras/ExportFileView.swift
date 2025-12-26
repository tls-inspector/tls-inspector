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
import Localization

public struct ExportFileView<Label: View>: View {
    private let fileUrl: URL
    private let label: Label
    @State private var showShareSheet = false

    public init(fileUrl: URL, @ViewBuilder label: () -> Label) {
        self.fileUrl = fileUrl
        self.label = label()
    }

    public var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                ShareLink(item: fileUrl) {
                    self.label
                }
            } else {
                Button {
                    self.showShareSheet = true
                } label: {
                    self.label
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ExportSheet(activityItems: [fileUrl])
        }
    }
}

// Apple added ShareLink in iOS 16, so we need to break out to add support for iOS 15 by falling back
// to using a share sheet
struct ExportSheet: UIViewControllerRepresentable {
    let activityItems: [URL]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
