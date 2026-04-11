// TLSKit
// Copyright (C) Ian Spence and other TLSKit Contributors
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import Testing
@testable import TLSKit

@Suite("HTTP") struct httpHeaderTests {
    @Test func getHeaders() async throws {
        let headers = HTTPHeaders()

        headers.add("X-Header-Name", "value1")
        headers.add("x-header-name", "value2")

        #expect(headers.get1("X-HEADER-NAME") == "value1")
        #expect(headers.get("X-header-NAME")?.contains("value2") ?? false)
    }

    @Test func parseHeaders() async throws {
        let data = Data([ 0x20, 0x4e, 0x6f, 0x74, 0x20, 0x46, 0x6f, 0x75, 0x6e, 0x64, 0x0d, 0x0a, 0x53, 0x65, 0x72, 0x76, 0x65, 0x72, 0x3a, 0x20, 0x2d, 0x0d, 0x0a, 0x58, 0x2d, 0x50, 0x6f, 0x77, 0x65, 0x72, 0x65, 0x64, 0x2d, 0x42, 0x79, 0x3a, 0x20, 0x2d, 0x0d, 0x0a, 0x44, 0x61, 0x74, 0x65, 0x3a, 0x20, 0x53, 0x61, 0x74, 0x2c, 0x20, 0x33, 0x31, 0x20, 0x41, 0x75, 0x67, 0x20, 0x32, 0x30, 0x32, 0x34, 0x20, 0x30, 0x30, 0x3a, 0x35, 0x32, 0x3a, 0x33, 0x36, 0x20, 0x47, 0x4d, 0x54, 0x0d, 0x0a, 0x43, 0x6f, 0x6e, 0x74, 0x65, 0x6e, 0x74, 0x2d, 0x4c, 0x65, 0x6e, 0x67, 0x74, 0x68, 0x3a, 0x20, 0x30 ])
        let headers = HTTPHeaders.fromResponse(data)

        #expect(headers.get1("X-Powered-By") == "-")
    }
}
