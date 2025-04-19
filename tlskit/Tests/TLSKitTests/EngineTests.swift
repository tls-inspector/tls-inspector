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

enum TLSEngine: Int, SuiteTrait {
    case NetworkFramework = 1
    case OpenSSL = 2
}

let testEngines: [TLSEngine] = [
    .NetworkFramework,
    .OpenSSL
]

@Suite("Engine Tests", .serialized) struct EngineTests {
    @Test("Basic Inspection", arguments: testEngines) func inspect(engineType: TLSEngine) async throws {
        let session = InspectionSession(engineType: TLSKit.EngineType(rawValue: engineType.rawValue)!)
        let request = InspectionRequest(address: "20.47.87.112", serverName: "dns.tlsinspector.com", ipVersion: .ipv4)
        let result = try await session.execute(request)
        #expect(result.tlsConnection.trust == .trusted)
        #expect(result.tlsConnection.certificates.count >= 3)

        let leaf = result.tlsConnection.certificates[0]
        #expect(leaf.signedTimestamps != nil)

        #expect((try? leaf.fingerprint(.md5)) != nil)
        #expect((try? leaf.fingerprint(.sha1)) != nil)
        #expect((try? leaf.fingerprint(.sha256)) != nil)
        #expect((try? leaf.fingerprint(.sha512)) != nil)
        #expect(try leaf.pemString().contains("BEGIN CERTIFICATE"))

        let scts = leaf.signedTimestamps!
        #expect(scts.count > 0)
        if (scts.count > 0) {
            #expect(scts[0].logName != nil)
        }
    }

    @Test("Inspect with Headers", arguments: testEngines) func inspectWithHeaders(engineType: TLSEngine) async throws {
        let session = InspectionSession(engineType: TLSKit.EngineType(rawValue: engineType.rawValue)!)
        let request = InspectionRequest(address: "ianspence.com")
        let result = try await session.execute(request)
        #expect(result.tlsConnection.trust == .trusted)
        #expect(result.tlsConnection.certificates.count >= 3)

        let leaf = result.tlsConnection.certificates[0]
        #expect(leaf.signedTimestamps != nil)

        #expect((try? leaf.fingerprint(.md5)) != nil)
        #expect((try? leaf.fingerprint(.sha1)) != nil)
        #expect((try? leaf.fingerprint(.sha256)) != nil)
        #expect((try? leaf.fingerprint(.sha512)) != nil)

        guard let httpServerInfo = result.httpServerInfo else {
            Issue.record("No HTTP server info")
            return
        }

        #expect(httpServerInfo.headers.all().count > 0)
        #expect(httpServerInfo.headers.get1("Content-Length") != nil)
    }

    @Test("Expired Leaf Certifificate", arguments: testEngines) func expiredLeaf(engineType: TLSEngine) async throws {
        let session = InspectionSession(engineType: .NetworkFramework)
        let request = InspectionRequest(address: "127.0.0.1", port: 8410, serverName: "localhost", checkCRL: false, checkOCSP: false, ipVersion: .ipv4, checkHTTP: false)
        let result = try await session.execute(request)
        #expect(result.tlsConnection.trust == .invalidDate)
    }

    @Test("Revoked by CRL", arguments: testEngines) func revokedCRL(engineType: TLSEngine) async throws {
        let session = InspectionSession(engineType: .NetworkFramework)
        let request = InspectionRequest(address: "127.0.0.1", port: 8408, serverName: "localhost", checkCRL: true, checkOCSP: false, ipVersion: .ipv4, checkHTTP: false)
        let result = try await session.execute(request)
        #expect(result.tlsConnection.trust == .revokedLeaf)
    }

    @Test("Revoked by OCSP", arguments: testEngines) func revokedOCSP(engineType: TLSEngine) async throws {
        let session = InspectionSession(engineType: .NetworkFramework)
        let request = InspectionRequest(address: "127.0.0.1", port: 8408, serverName: "localhost", checkCRL: false, checkOCSP: true, ipVersion: .ipv4, checkHTTP: false)
        let result = try await session.execute(request)
        #expect(result.tlsConnection.trust == .revokedLeaf)
    }
}
