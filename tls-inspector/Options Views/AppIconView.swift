// TLS Inspector
// Copyright (C) 2025 Ian Spence
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

private struct iconPreview {
    public let name: String
    public let icon: ImageResource
    public let iconName: String?

    public init(_ name: String, _ icon: ImageResource, _ iconName: String?) {
        self.name = name
        self.icon = icon
        self.iconName = iconName
    }
}

public struct AppIconView: View {
    private let generalIcons: [iconPreview] = [
        .init(Localize.icondefault(), .previewIconDefault, nil),
        .init(Localize.iconlight(), .previewIconLight, "IconLight"),
        .init(Localize.icondark(), .previewIconDark, "IconDark"),
        .init(Localize.iconskew(), .previewIconSkeu, "IconSkeu"),
        .init(Localize.iconslate(), .previewIconSlate, "IconSlate"),
    ]
    private let specialIcons: [iconPreview] = [
        .init(Localize.iconpride(), .previewIconPride, "IconPride"),
        .init(Localize.icontrans(), .previewIconTrans, "IconTrans"),
    ]

    public var body: some View {
        List {
            Section(Localize.general()) {
                ForEach(generalIcons, id: \.name) { icon in
                    ListButton {
                        UIApplication.shared.setAlternateIconName(icon.iconName)
                    } label: {
                        HStack {
                            Image(icon.icon)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            Text(icon.name)
                        }
                    }
                }
            }
            Section {
                ForEach(specialIcons, id: \.name) { icon in
                    ListButton {
                        UIApplication.shared.setAlternateIconName(icon.iconName)
                    } label: {
                        HStack {
                            Image(icon.icon)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            Text(icon.name)
                        }
                    }
                }
            } header: {
                Text(Localize.special())
            } footer: {
                Text(Localize.appiconfooter())
            }
        }
        .navigationTitle(Localize.appicon())
    }
}
