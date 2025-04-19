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

public struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    VStack {
                        Image(systemName: "lock.circle.fill")
                            .resizable(resizingMode: .stretch)
                            .foregroundColor(Color.white)
                            .frame(width: 75.0, height: 75.0)
                        Text("TLS Inspector")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height*0.40)
                    .background(.linearGradient(.init(colors: [Color("GradientLeft", bundle: nil), Color("GradientRight", bundle: nil)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                }
                List {
                    Section {
                        Text("Share TLS Inspector")
                        Text("Rate in App Store")
                    } header: {
                        Text("Share & Feedback")
                    } footer: {
                        Text("App: 2.8.3 (135), OpenSSL: 3.4.1, curl: 8.11.1")
                    }
                    Section("Follow Us") {
                        Text("Follow us on Mastodon")
                        Text("Follow us on Bluesky")
                    }
                    Section("Get Involved") {
                        Text("Contribute to TLS Inspector")
                        Text("Provide Feedback")
                    }
                    Section("More from the Developer") {
                        Text("DNS Inspector")
                    }
                    Section {
                        //
                    } footer: {
                        Text("Trans rights!")
                    }
                }
            }
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    .tint(.white)
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
        }
    }
}
