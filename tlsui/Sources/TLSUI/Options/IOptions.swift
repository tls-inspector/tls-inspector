// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
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

import TLSKit

public enum CryptoEngine: String, Sendable, Codable {
    case NetworkFramework = "network_framework"
    case OpenSSL = "openssl"

    static func allValues() -> [CryptoEngine] {
        return [
            .NetworkFramework,
            .OpenSSL,
        ]
    }

    public func intValue() -> Int {
        switch self {
        case .NetworkFramework:
            return 1
        case .OpenSSL:
            return 3
        }
    }

    public static func from(int: Int) -> CryptoEngine? {
        switch int {
        case 1:
            return .NetworkFramework
        case 3:
            return .OpenSSL
        default:
            return nil
        }
    }

    public func toTLSKit() -> EngineType {
        switch self {
        case .NetworkFramework:
            return .NetworkFramework
        case .OpenSSL:
            return .OpenSSL
        }
    }
}

public enum IPVersion: String, Identifiable, Sendable, Codable {
    case Automatic = "automatic"
    case IPv4 = "ipv4"
    case IPv6 = "ipv6"

    public var id: Self { self }

    public static func allValues() -> [IPVersion] {
        return [
            .Automatic,
            .IPv4,
            .IPv6,
        ]
    }

    public func intValue() -> Int {
        switch self {
        case .Automatic:
            return 1
        case .IPv4:
            return 2
        case .IPv6:
            return 3
        }
    }

    public static func from(int: Int) -> IPVersion? {
        switch int {
        case 1:
            return .Automatic
        case 2:
            return .IPv4
        case 3:
            return .IPv6
        default:
            return nil
        }
    }

    public func toTLSKit() -> IPAddressVersion? {
        switch self {
        case .Automatic:
            return nil
        case .IPv4:
            return .ipv4
        case .IPv6:
            return .ipv6
        }
    }
}

@MainActor
public protocol IOptions {
    func firstRunComplete() -> Bool
    func rememberRecentLookups() -> Bool
    func showTips() -> Bool
    func getHttpHeaders() -> Bool
    func queryOcsp() -> Bool
    func checkCrl() -> Bool
    func showFingerprintMd5() -> Bool
    func showFingerprintSha1() -> Bool
    func showFingerprintSha256() -> Bool
    func showFingerprintSha512() -> Bool
    func cryptoEngine() -> CryptoEngine
    func ipVersion() -> IPVersion
    func preferredCiphers() -> String
    func contactNagDismissed() -> Bool
    func advancedSettingsNagDismissed() -> Bool
    func treatUnrecognizedAsTrusted() -> Bool
    func appLanguage() -> String
    func inspectTimeout() -> Int
    func verboseLogging() -> Bool
}
