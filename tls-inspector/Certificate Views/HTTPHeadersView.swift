// TLS Inspector
// Copyright (C) 2024 Ian Spence
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

public struct HTTPHeadersView: View {
    private let keys: [String]
    private let headers: HTTPHeaders

    public init(headers: HTTPHeaders) {
        self.keys = headers.all().keys.sorted()
        self.headers = headers
    }

    public var body: some View {
        List {
            ForEach(keys, id: \.self) { key in
                ForEach(headers.get(key)!, id: \.self) { value in
                    HStack {
                        Text(key)
                        Spacer()
                        Text(value).monospaced()
                    }
                }
            }
        }
        .navigationTitle(Localize.httpheaders())
    }
}
