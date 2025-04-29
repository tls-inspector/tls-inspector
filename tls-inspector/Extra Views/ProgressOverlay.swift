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

extension View {
    func progressOverlay(presented: Binding<Bool>) -> some View {
        modifier(ProgressOverlay(presented: presented))
    }
}

struct ProgressOverlay: ViewModifier {
    let presented: Binding<Bool>
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if presented.wrappedValue {
            content.overlay {
                GeometryReader { geo in
                    VStack(alignment: .center) {
                        VStack(alignment: .center) {
                            ProgressView().controlSize(.large)
                            Text(Localize.pleasewait())
                        }
                        .padding()
                        .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.10))
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .background(colorScheme == .dark ? .black.opacity(0.01) : .white.opacity(0.01))
                }
            }
        } else {
            content
        }
    }
}
