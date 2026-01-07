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
import TLSUI

public struct ProxyNoticeView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        Navigation {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text(Localize.proxynotice())
                        Link(destination: URL(string: "https://tlsinspector.com/wiki/About-HTTPS-Proxies")!) {
                            Text(Localize.learnmore())
                        }
                    }
                }.padding(.bottom)
                SafetyWarningView(title: Localize.danger(), message: Localize.proxydanger())
                    .padding()
                    .background(IRoundedRectangle(backgroundColor: .clear, borderColor: .red, borderWidth: 2))
                Spacer()
                Button {
                    NotificationCenter.default.post(name: closedInspectionViewNotification, object: nil)
                    dismiss()
                } label: {
                    Text(Localize.dismiss())
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding(5)
                }
                .modify {
                    if #available(iOS 26.0, *) {
                        $0.buttonStyle(.glassProminent)
                    } else {
                        $0.buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .navigationTitle(Localize.notice())
        }
    }
}
