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

public struct IRoundedRectangle: View {
    public let backgroundColor: Color
    public let borderColor: Color
    public let borderWidth: CGFloat

    public init(backgroundColor: Color, borderColor: Color, borderWidth: CGFloat = 2) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .modify {
                if #available(iOS 17.0, *) {
                    $0.fill(backgroundColor)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                } else {
                    $0.fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                }
            }
    }
}
