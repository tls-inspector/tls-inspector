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

@Suite("Inspection Target") struct InspectionTargetTests {
    @Test func testParse() async throws {
        let ipv4OnlyTarget = try await InspectionTarget.with(address: "127.0.0.1", port: 443, servername: nil)
        #expect(ipv4OnlyTarget.ipAddress.string == "127.0.0.1")
        #expect(ipv4OnlyTarget.port == 443)
        #expect(ipv4OnlyTarget.serverName == nil)

        let ipv4WithPortTarget = try await InspectionTarget.with(address: "127.0.0.1:8443", port: 443, servername: nil)
        #expect(ipv4WithPortTarget.ipAddress.string == "127.0.0.1")
        #expect(ipv4WithPortTarget.port == 8443)
        #expect(ipv4WithPortTarget.serverName == nil)

        let ipv6OnlyTarget = try await InspectionTarget.with(address: "fe80:bad:beef::1", port: 443, servername: nil)
        #expect(ipv6OnlyTarget.ipAddress.string == "fe80:bad:beef::1")
        #expect(ipv6OnlyTarget.port == 443)
        #expect(ipv6OnlyTarget.serverName == nil)

        let ipv6WithPortTarget = try await InspectionTarget.with(address: "[fe80:bad:beef::1]:8443", port: 443, servername: nil)
        #expect(ipv6WithPortTarget.ipAddress.string == "fe80:bad:beef::1")
        #expect(ipv6WithPortTarget.port == 8443)
        #expect(ipv6WithPortTarget.serverName == nil)

        let hostnameOnlyTarget = try await InspectionTarget.with(address: "example.com", port: 443, servername: nil, ipVersion: .ipv4)
        #expect(!hostnameOnlyTarget.ipAddress.string.isEmpty)
        #expect(hostnameOnlyTarget.port == 443)
        #expect(hostnameOnlyTarget.serverName == "example.com")

        let hostnameWithPortTarget = try await InspectionTarget.with(address: "example.com:8443", port: 443, servername: nil, ipVersion: .ipv4)
        #expect(!hostnameWithPortTarget.ipAddress.string.isEmpty)
        #expect(hostnameWithPortTarget.port == 8443)
        #expect(hostnameWithPortTarget.serverName == "example.com")
    }
}
