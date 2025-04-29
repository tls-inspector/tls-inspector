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

public struct ListButton<Label: View>: View {
    public let label: Label
    public let onTap: () -> Void
    public let showDisclosureIndicator: Bool
    @State private var isLongPressing: Bool = false
    @GestureState private var isDragging = false

    public init(showDisclosureIndicator: Bool = true, onTap: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.showDisclosureIndicator = showDisclosureIndicator
        self.onTap = onTap
    }

    public var body: some View {
        HStack {
            label
            if showDisclosureIndicator {
                Spacer()
                Image(systemName: "chevron.right")
                    .opacity(0.25)
                    .imageScale(.small)
            }
        }
        .contentShape(Rectangle())
        .listRowBackground(Rectangle().fill(isLongPressing ? Color.listButtonSelectedBackground : Color.listButtonBackground))
        .onTapGesture(perform: onTap)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .updating($isDragging, body: { _, _, _ in
                self.isLongPressing = true
            })
            .onEnded({ _ in
                self.isLongPressing = false
            })
        )
    }
}
