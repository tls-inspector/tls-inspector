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
import Network
import IDNA

/// Describes a request to inspect a TLS connection and optional HTTP server
public struct InspectionRequest: Codable, Equatable, Sendable, CustomStringConvertible {
    /// The host address. This can be an IP address or a host name.
    public let address: String
    /// The port number.
    public let port: UInt16
    /// The server name. This is used for SNI, not for name resolution. If nil then SNI is not used.
    public let serverName: String?
    /// If certificate revocation lists should be checked for revoked certificates.
    public let checkCRL: Bool
    /// If an online certificate status server should be queried for revoked certificates.
    public let checkOCSP: Bool
    /// The IP version to use for the outbound connection. If nil then automatic is assumed.
    public let ipVersion: IPAddressVersion?
    /// If a HTTP request should be sent to the host to collect HTTP server information
    public let checkHTTP: Bool
    /// The number of seconds to wait before failing an incomplete inspection request.
    public let timeoutSeconds: UInt8
    /// Application names to pass within the TLS handshake
    public let alpn: [String]?

    /// Create a new inspection request using default values.
    public init(address: String, port: UInt16 = 443, serverName: String? = nil, checkCRL: Bool = false, checkOCSP: Bool = true, ipVersion: IPAddressVersion? = nil, checkHTTP: Bool = true, timeoutSeconds: UInt8 = 10, alpn: [String]? = nil) {
        self.address = address
        self.port = port
        self.serverName = serverName
        self.checkCRL = checkCRL
        self.checkOCSP = checkOCSP
        self.ipVersion = ipVersion
        self.checkHTTP = checkHTTP
        self.timeoutSeconds = timeoutSeconds
        self.alpn = alpn
    }

    public var description: String {
        return String(stringLiteral: "InspectionRequest(address: \(self.address), port: \(self.port), serverName: \(self.serverName ?? "nil"), checkCRL: \(self.checkCRL), checkOCSP: \(self.checkOCSP), ipVersion: \(self.ipVersion?.rawValue ?? -1), checkHTTP: \(self.checkHTTP), timeoutSeconds: \(self.timeoutSeconds), alpn: \(self.alpn ?? [])")
    }

    @available(iOS 13.0, *)
    internal func getInspectionTarget() async throws -> InspectionTarget {
        return try await InspectionTarget.with(address: self.address, port: self.port, servername: self.serverName, ipVersion: self.ipVersion)
    }

    internal func getInspectionTarget(_ complete: @escaping (Result<InspectionTarget, TLSKitError>) -> Void) {
        InspectionTarget.with(address: self.address, port: self.port, servername: self.serverName, ipVersion: self.ipVersion, complete: complete)
    }

    internal var timeoutDispatchTime: DispatchTime {
        return DispatchTime.now().adding(seconds: self.timeoutSeconds)
    }
}
