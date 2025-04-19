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

@Suite("Trust") struct RootCAAPIClientTest {
    init() {
        RootCAAPIClient.apiHost = "http://127.0.0.1:8414"
    }

    @Test func getMetadata() async throws {
        let latestTag = try RootCAAPIClient.getLatestTag()
        #expect(!latestTag.isEmpty)
        let metadata = try RootCAAPIClient.getMetadata(tag: latestTag)
        #expect(metadata.apple.num_certs == 154)
        #expect(metadata.google.num_certs == 134)
        #expect(metadata.microsoft.num_certs == 246)
        #expect(metadata.mozilla.num_certs == 151)
        #expect(metadata.tls_inspector.num_certs == 116)
    }
}
