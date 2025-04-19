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

import Testing
@testable import TLSKit

@Suite("Curl") struct curlTests {
    @Test func httpGet() async throws {
        let curl = try CurlClient(url: "https://ianspence.com")
        let result = curl.get()

        switch result {
        case .success(let response):
            #expect(response.headers.get1("Content-Type")?.contains("text/html") ?? false, "Content type must be defined")
            #expect(response.body.count > 0, "Response must have a body")
        case .failure(let error):
            Issue.record(error, "GET request failed")
        }
    }
}
