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

/// IP address versions
public enum IPAddressVersion: Int, Codable, Sendable {
    case ipv4 = 4
    case ipv6 = 6

    internal func family() -> Int32 {
        switch self {
        case .ipv4:
            return AF_INET
        case .ipv6:
            return AF_INET6
        }
    }
}

/// Describes an IP Address
public struct IPAddress: Equatable, Sendable, Hashable, CustomStringConvertible {
    /// The address family (version)
    public let family: IPAddressVersion
    /// The address in human-readable form
    public let string: String
    /// The address in binary form
    public let binary: Data

    public var description: String {
        return string
    }

    internal init(_ string: String) throws {
        self.family = string.contains(":") ? .ipv6 : .ipv4

        switch family {
        case .ipv4:
            var buffer = ContiguousArray<UInt8>(repeating: 0, count: 4)
            let r = buffer.withUnsafeMutableBufferPointer { b in
                return inet_pton(AF_INET, string, b.baseAddress)
            }
            if r != 1 {
                throw TLSKitError.invalidData("Invalid IP address")
            }

            self.string = string
            self.binary = Data([buffer[0], buffer[1], buffer[2], buffer[3]])
        case .ipv6:
            var buffer = ContiguousArray<UInt8>(repeating: 0, count: 16)
            let r = buffer.withUnsafeMutableBufferPointer { b in
                return inet_pton(AF_INET6, string, b.baseAddress)
            }
            if r != 1 {
                throw TLSKitError.invalidData("Invalid IP address")
            }

            self.string = string
            self.binary = Data([buffer[0], buffer[1],
                                buffer[2], buffer[3],
                                buffer[4], buffer[5],
                                buffer[6], buffer[7],
                                buffer[8], buffer[9],
                                buffer[10], buffer[11],
                                buffer[12], buffer[13],
                                buffer[14], buffer[15]])
        }
    }

    internal init(_ data: Data) throws {
        if data.count == 4 {
            self.family = .ipv4
            self.string = try IPAddress.v4(data)
            self.binary = data
        } else if data.count == 16 {
            self.family = .ipv6
            self.string = try IPAddress.v6(data)
            self.binary = data
        } else {
            throw TLSKitError.invalidData("Unrecognized IP Address byte format with length \(data.count)")
        }
    }

    internal static func isValid(_ addr: String) -> Bool {
        do {
            _ = try IPAddress(addr)
            return true
        } catch {
            return false
        }
    }

    internal static func from(addrinfo: addrinfo) throws -> IPAddress {
        let addressString: String

        switch Int32(addrinfo.ai_family) {
        case AF_INET:
            addressString = try addrinfo.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { sockAddrInPtr in
                var sockAddrIn = sockAddrInPtr.pointee
                let length = Int(INET_ADDRSTRLEN) + 2
                var buffer = [CChar](repeating: 0, count: length)
                guard inet_ntop(AF_INET, &sockAddrIn.sin_addr, &buffer, socklen_t(length)) != nil else {
                    throw TLSKitError.internalError("Unable to get IP address from socket")
                }
                guard let addressString = NSString(utf8String: buffer) as? String else {
                    throw TLSKitError.internalError("Unable to get IP address from socket")
                }
                return addressString
            }

        case AF_INET6:
            addressString = try addrinfo.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sockAddrIn6Ptr in
                var sockAddrIn6 = sockAddrIn6Ptr.pointee
                let length = Int(INET6_ADDRSTRLEN) + 2
                var buffer = [CChar](repeating: 0, count: length)
                guard inet_ntop(AF_INET6, &sockAddrIn6.sin6_addr, &buffer, socklen_t(length)) != nil else {
                    throw TLSKitError.internalError("Unable to get IP address from socket")
                }
                guard let addressString = NSString(utf8String: buffer) as? String else {
                    throw TLSKitError.internalError("Unable to get IP address from socket")
                }
                return addressString
            }
        default:
            throw TLSKitError.invalidData("Unknown address family \(addrinfo.ai_family)")
        }

        return try IPAddress(addressString)
    }

    internal static func from(socket fd: Int32) throws -> IPAddress {
        var addr = sockaddr()
        var addrLen = socklen_t(MemoryLayout<sockaddr>.size)
        let result = withUnsafeMutablePointer(to: &addr) { addrPtr in
            return getpeername(fd, addrPtr, &addrLen)
        }
        if result != 0 {
            printError("[\(#fileID):\(#line)] getpeername returned 0")
            throw TLSKitError.internalError("Unable to get IP address from socket")
        }

        let addressString = try withUnsafePointer(to: addr) { socketAddressPointer in
            let socketAddress = socketAddressPointer.pointee

            var addressString: NSString?

            switch Int32(socketAddress.sa_family) {
            case AF_INET:
                addressString = socketAddressPointer.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { sockAddrInPtr in
                    var sockAddrIn = sockAddrInPtr.pointee
                    let length = Int(INET_ADDRSTRLEN) + 2
                    var buffer = [CChar](repeating: 0, count: length)
                    guard inet_ntop(AF_INET, &sockAddrIn.sin_addr, &buffer, socklen_t(length)) != nil else {
                        return nil
                    }
                    return NSString(utf8String: buffer)
                }

            case AF_INET6:
                addressString = socketAddressPointer.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sockAddrIn6Ptr in
                    var sockAddrIn6 = sockAddrIn6Ptr.pointee
                    let length = Int(INET6_ADDRSTRLEN) + 2
                    var buffer = [CChar](repeating: 0, count: length)
                    guard inet_ntop(AF_INET6, &sockAddrIn6.sin6_addr, &buffer, socklen_t(length)) != nil else {
                        return nil
                    }
                    return NSString(utf8String: buffer)
                }
            default:
                throw TLSKitError.invalidData("Unknown address family \(socketAddress.sa_family)")
            }

            guard let addressString = addressString as? String else {
                throw TLSKitError.internalError("Unable to get IP address from socket")
            }

            return addressString
        }

        return try IPAddress(addressString)
    }

    /// Read the binary representation of an IPv4 address and return a formatted string
    /// - Parameter data: The 4 bytes of an IPv4 address. Must be exactly 4 bytes.
    /// - Returns: A string representing an IPv4 address
    internal static func v4(_ data: Data) throws -> String {
        if data.count > 4 {
            printError("[\(#fileID):\(#line)] Invalid IPv4 address: expecting >= 4 bytes got \(data.count)")
            throw TLSKitError.invalidData("Invalid IPv4 address")
        }

        var buffer = ContiguousArray<Int8>(repeating: 0, count: Int(INET_ADDRSTRLEN))
        return data.withUnsafeBytes {
            let addr = $0.assumingMemoryBound(to: sockaddr_in.self)
            return buffer.withUnsafeMutableBufferPointer { buf in
                return String(cString: inet_ntop(AF_INET, addr.baseAddress, buf.baseAddress, UInt32(buf.count)))
            }
        }
    }

    /// Read the binary representation of an IPv6 address and return a formatted string
    /// - Parameter data: The 16 bytes of an IPv6 address. Must be exactly 16 bytes.
    /// - Returns: A string representing an IPv6 address
    internal static func v6(_ data: Data) throws -> String {
        if data.count > 16 {
            printError("[\(#fileID):\(#line)] Invalid IPv6 address: expecting >= 16 bytes got \(data.count)")
            throw TLSKitError.invalidData("Invalid IPv6 address")
        }

        var buffer = ContiguousArray<Int8>(repeating: 0, count: Int(INET6_ADDRSTRLEN))
        return data.withUnsafeBytes {
            let addr = $0.assumingMemoryBound(to: sockaddr_in6.self)
            return buffer.withUnsafeMutableBufferPointer { buf in
                return String(cString: inet_ntop(AF_INET6, addr.baseAddress, buf.baseAddress, UInt32(buf.count)))
            }
        }
    }

    /// Returns the expanded form of any shorthand address. For example, ::1 returns 0000:0000:0000:0000:0000:0000:0000:0001
    internal func expanded() -> String {
        switch family {
        case .ipv4:
            let buffer = Array(self.binary)

            return String(format: "%i.%i.%i.%i",
                          buffer[0], buffer[1],
                          buffer[2], buffer[3])
        case .ipv6:
            let buffer = Array(self.binary)

            return String(format: "%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x",
                          buffer[0], buffer[1],
                          buffer[2], buffer[3],
                          buffer[4], buffer[5],
                          buffer[6], buffer[7],
                          buffer[8], buffer[9],
                          buffer[10], buffer[11],
                          buffer[12], buffer[13],
                          buffer[14], buffer[15])
        }
    }

    /// Gets and removes a port suffix from the given address. If the address does not contain a port suffix the address
    /// is not changed. Throws if a port suffix is provided but has an invalid port.
    /// - Parameter address: An IP address or hostname with an optional port suffix. Will be replaced with a copy
    /// without the port.
    /// - Returns: The port if one was specified or nil
    internal static func getAndStripPort(_ address: inout String) throws -> UInt16? {
        let portPattern = RegularExpression(":\\d+$")
        guard var colonAndPort = portPattern.firstMatch(in: address) else {
            return nil
        }

        colonAndPort.removeFirst()

        guard let port = UInt16(colonAndPort) else {
            throw TLSKitError.invalidData("Invalid port number from string '\(colonAndPort)'")
        }

        address = portPattern.replaceAllMatches(in: address, with: "")
        return port
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.binary == rhs.binary
    }
}
