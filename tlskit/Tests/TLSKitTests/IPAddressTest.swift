// TLSKit
// Copyright (C) 2024 Ian Spence
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

@Suite("IP Addresses") struct IPAddressTest {
    @Test func ipv4() throws {
        let ip = try IPAddress("127.0.0.1")
        let compare = try IPAddress(ip.binary)

        #expect(ip.family == compare.family)
        #expect(ip.string == compare.string)
    }

    @Test func invalidIpv4() throws {
        do {
            _ = try IPAddress("257.0.0.1")
            Issue.record("No exception thrown for invalid IPv4 address")
        } catch {
            // Pass
        }

        do {
            _ = try IPAddress("257.0.0.1".utf8())
            Issue.record("No exception thrown for invalid IPv4 address")
        } catch {
            // Pass
        }
    }

    @Test func ipv6() throws {
        let ip = try IPAddress("::1")
        let compare = try IPAddress(ip.binary)

        #expect(ip.family == compare.family)
        #expect(ip.string == compare.string)
        #expect(ip.expanded() == "0000:0000:0000:0000:0000:0000:0000:0001")
    }

    @Test func invalidIPv6() throws {
        do {
            _ = try IPAddress("h::1")
            Issue.record("No exception thrown for invalid IPv6 address")
        } catch {
            // Pass
        }

        do {
            _ = try IPAddress("0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0".utf8())
            Issue.record("No exception thrown for invalid IPv6 address")
        } catch {
            // Pass
        }
    }
}
