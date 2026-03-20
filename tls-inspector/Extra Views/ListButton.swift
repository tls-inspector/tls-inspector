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

    public init(showDisclosureIndicator: Bool = true, onTap: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.showDisclosureIndicator = showDisclosureIndicator
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            self.onTap()
        } label: {
            HStack {
                self.label
                if self.showDisclosureIndicator {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
