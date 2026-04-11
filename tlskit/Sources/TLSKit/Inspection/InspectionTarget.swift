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
import DNSKit

/// Describes the target for performing an inspection
internal struct InspectionTarget: CustomStringConvertible {
    /// The IP address to connect to
    let ipAddress: IPAddress
    /// The port number to connect to
    let port: UInt16
    /// The server name for SNI
    let serverName: String?

    var description: String {
        return String(stringLiteral: "InspectionTarget(ipAddress: \(self.ipAddress), port: \(self.port), serverName: \(self.serverName ?? "nil"))")
    }

    internal init(ipAddress: IPAddress, port: UInt16, serverName: String? = nil) {
        self.ipAddress = ipAddress
        self.port = port
        self.serverName = serverName
    }

    internal func endpoint() -> NWEndpoint {
        return NWEndpoint.hostPort(host: .init(self.ipAddress.string), port: .init(rawValue: self.port)!)
    }

    internal func socketAddress() -> String {
        switch self.ipAddress.family {
        case .ipv4:
            return String(stringLiteral: "\(self.ipAddress.string):\(self.port)")
        case .ipv6:
            return String(stringLiteral: "[\(self.ipAddress.string)]:\(self.port)")
        }
    }

    /// Resolve the user-provided inspection target.
    ///
    /// Presently this method does not actually perform any asynchronous operations, however this will change in a
    /// future version of TLSKit
    ///
    /// - Parameters:
    ///   - address: The inspection target. Supported formats are:
    ///     - Hostname: `example.com`
    ///     - Hostname with port: `example.com:443`
    ///     - IPv4 address: `127.0.0.1`
    ///     - IPv4 address with port: `127.0.0.1:443`
    ///     - IPv6 address: `fe80::1`
    ///     - Wrapped IPv6 address: `[fe80::1]`
    ///     - IPv6 address with port: `[fe80::1]:443`
    ///   - port: The default port to use if one is not specified in the address
    ///   - servername: The servername to use. If address is a domain name and this value is nil, then the value of
    ///   address if used.
    ///   - ipVersion: The preferred IP version to use for resolution. If nil then automatic.
    /// - Returns: An inspection target.
    @available(iOS 13.0, *)
    internal static func with(address: String, port: UInt16, servername: String?, ipVersion: IPAddressVersion? = nil) async throws -> InspectionTarget {
        try await withCheckedThrowingContinuation { continuation in
            InspectionTarget.with(address: address, port: port, servername: servername) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Resolve the user-provided inspection target.
    ///
    /// Presently this method does not actually perform any asynchronous operations, however this will change in a
    /// future version of TLSKit
    ///
    /// - Parameters:
    ///   - address: The inspection target. Supported formats are:
    ///     - Hostname: `example.com`
    ///     - Hostname with port: `example.com:443`
    ///     - IPv4 address: `127.0.0.1`
    ///     - IPv4 address with port: `127.0.0.1:443`
    ///     - IPv6 address: `fe80::1`
    ///     - Wrapped IPv6 address: `[fe80::1]`
    ///     - IPv6 address with port: `[fe80::1]:443`
    ///   - port: The default port to use if one is not specified in the address
    ///   - serverName: The servername to use. If address is a domain name and this value is nil, then the value of
    ///   address if used.
    ///   - ipVersion: The preferred IP version to use for resolution. If nil then automatic.
    ///   - complete: Called with the result of the resolution of the inspection target.
    internal static func with(address: String, port defaultPort: UInt16, servername defaultServername: String?, ipVersion: IPAddressVersion? = nil, complete: @escaping (Result<InspectionTarget, TLSKitError>) -> Void) {
        var port = defaultPort
        let serverName = defaultServername

        // Strip protocol
        let protocolPattern = RegularExpression("^[a-z]+://")
        var target = protocolPattern.replaceAllMatches(in: address, with: "").lowercased()

        // Replace any path component
        if target.contains("/") {
            target = String(target.split(separator: "/").first!)
        }

        // First check if the target is already an IP address, if so then pack it up, we're done here.
        if let ipAddress = try? IPAddress(target) {
            complete(.success(InspectionTarget(ipAddress: ipAddress, port: port, serverName: serverName)))
            return
        }

        // Next check if it's an IPv6 addressed wrapped in [] with optional port
        let wrappedIPv6AddressPattern = RegularExpression("\\[[a-fA-F0-9:]+\\]")
        if wrappedIPv6AddressPattern.matches(in: target) {
            guard var wrappedAddress = wrappedIPv6AddressPattern.firstMatch(in: target) else {
                complete(.failure(TLSKitError.invalidData("Invalid inspection target \(target)")))
                return
            }
            if wrappedAddress.starts(with: "[") {
                wrappedAddress.removeFirst()
            }
            if wrappedAddress.hasSuffix("]") {
                wrappedAddress.removeLast()
            }
            let ipAddress: IPAddress
            do {
                ipAddress = try IPAddress(wrappedAddress)
            } catch {
                printError("[\(#fileID):\(#line)] Invalid IPv6 address \(wrappedAddress)")
                complete(.failure(.invalidData(error.localizedDescription)))
                return
            }

            do {
                let oPort = try IPAddress.getAndStripPort(&target)
                if let p = oPort {
                    port = p
                }
            } catch {
                printError("[\(#fileID):\(#line)] Invalid port suffix on \(target): \(error)")
                complete(.failure(.invalidData(error.localizedDescription)))
                return
            }

            complete(.success(InspectionTarget(ipAddress: ipAddress, port: port, serverName: serverName)))
            return
        }

        // We've exhausted all support IP address formats, so assume it's a domain name and we need to resolve it.

        // First strip the port if present
        do {
            let oPort = try IPAddress.getAndStripPort(&target)
            if let p = oPort {
                port = p

                // Target no longer has a port suffix, try to parse it as an address again to allow for IPv4:port
                if let ipAddress = try? IPAddress(target) {
                    complete(.success(InspectionTarget(ipAddress: ipAddress, port: port, serverName: serverName)))
                    return
                }
            }
        } catch {
            printError("[\(#fileID):\(#line)] Invalid port suffix on \(target): \(error)")
            complete(.failure(.invalidData(error.localizedDescription)))
            return
        }

        // Then do punycode/idna if needed
        do {
            let name = try Punycode.toASCII(target)
            let ipAddress = try Resolver.resolveAddress(fromDomain: target, addressFamily: ipVersion)
            complete(.success(InspectionTarget(ipAddress: ipAddress, port: port, serverName: target)))
        } catch {
            printError("[\(#fileID):\(#line)] Unable to resolve inspection target: \(error)")
            complete(.failure(.invalidData(error.localizedDescription)))
            return
        }
    }
}
