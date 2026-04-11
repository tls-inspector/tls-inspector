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

public struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tapCount = 0
    @State private var showQuote = false

    public var body: some View {
        GeometryReader { geometry in
            Navigation {
                VStack(spacing: 0) {
                    VStack {
                        Image(systemName: "lock.circle.fill")
                            .resizable(resizingMode: .stretch)
                            .foregroundColor(Color.white)
                            .frame(width: 75.0, height: 75.0)
                            .onTapGesture {
                                self.tapCount += 1
                                if self.tapCount >= 5 {
                                    self.showQuote = true
                                }
                            }
                        Text("TLS Inspector")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height*0.30)
                    .background(.linearGradient(.init(colors: [Color("GradientLeft", bundle: nil), Color("GradientRight", bundle: nil)]), startPoint: .bottomLeading, endPoint: .topTrailing))
                    AboutTableViewRepresentable()
                }
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CloseButton {
                            dismiss()
                        }
                        .tint(.white)
                    }
                }
            }
            .alert(FunStuff.randomQuote(), isPresented: $showQuote, actions: {
                Button(Localize.dismiss()) {
                    self.tapCount = 0
                }
            })
            .background(Color(uiColor: UIColor.systemGroupedBackground))
        }
    }
}
