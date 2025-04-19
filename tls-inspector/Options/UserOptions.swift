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

import SwiftUI
import TLSKit

private enum AppDefaultsKeys: String {
    case firstRunComplete = "first_run_complete"
    case rememberRecentLookups = "remember_recent_lookups"
    case showTips = "show_tips"
    case getHttpHeaders = "get_http_headers"
    case queryOcsp = "query_ocsp"
    case checkCrl = "check_crl"
    case showFingerprintMd5 = "fingerprint_md5"
    case showFingerprintSha1 = "fingerprint_sha128"
    case showFingerprintSha256 = "fingerprint_sha256"
    case showFingerprintSha512 = "fingerprint_sha512"
    case preferredCiphers = "preferred_ciphers"
    case contactNagDismissed = "contact_nag_dismissed"
    case advancedSettingsNagDismissed = "advanced_settings_nag_dismissed"
    case cryptoEngine = "crypto_engine"
    case ipVersion = "use_ip_version"
    case optionsSchemaVersion = "options_schema_version"
    case treatUnrecognizedAsTrusted = "treat_unrecognized_as_trusted"
    case appLanguage = "app_language"
    case inspectTimeout = "inspect_timeout"
}

private final class AppDefaults: Sendable {
    nonisolated(unsafe) private static let s = UserDefaults(suiteName: "group.com.ecnepsnai.TLS-Inspector")!

    public static func get<T>(_ key: AppDefaultsKeys) -> T? {
        let r = s.value(forKey: key.rawValue) as? T
        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Get AppDefault: \(key) = \(String(describing: r))")
        return r
    }

    public static func get<T>(_ key: AppDefaultsKeys, _ defaultValue: T) -> T {
        return get(key) ?? defaultValue
    }

    public static func set(_ key: AppDefaultsKeys, _ value: Any) {
        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Set AppDefault: \(key) = \(value)")
        NotificationCenter.default.post(name: optionsChangedNotification, object: nil)
        return s.set(value, forKey: key.rawValue)
    }
}

public enum CryptoEngine: String, Sendable, Codable {
    case NetworkFramework = "network_framework"
    case OpenSSL = "openssl"

    static func allValues() -> [CryptoEngine] {
        return [
            .NetworkFramework,
            .OpenSSL,
        ]
    }

    func intValue() -> Int {
        switch self {
        case .NetworkFramework:
            return 1
        case .OpenSSL:
            return 3
        }
    }

    static func from(int: Int) -> CryptoEngine? {
        switch int {
        case 1:
            return .NetworkFramework
        case 3:
            return .OpenSSL
        default:
            return nil
        }
    }

    func engineType() -> EngineType {
        switch self {
        case .NetworkFramework:
            return .NetworkFramework
        case .OpenSSL:
            return .OpenSSL
        }
    }
}

public enum IPVersion: String, Sendable, Codable {
    case Automatic = "automatic"
    case IPv4 = "ipv4"
    case IPv6 = "ipv6"

    static func allValues() -> [IPVersion] {
        return [
            .Automatic,
            .IPv4,
            .IPv6,
        ]
    }

    func intValue() -> Int {
        switch self {
        case .Automatic:
            return 1
        case .IPv4:
            return 2
        case .IPv6:
            return 3
        }
    }

    static func from(int: Int) -> IPVersion? {
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
}

@MainActor
public final class UserOptions {
    public static let current = UserOptions()
    private static var _verboseLogging = false
    private static var _inspectionsWithVerboseLogging = 0

    var firstRunComplete: Bool {
        get {
            return AppDefaults.get(.firstRunComplete, false)
        }
        set {
            AppDefaults.set(.firstRunComplete, newValue)
        }
    }

    var rememberRecentLookups: Bool {
        get {
            return AppDefaults.get(.rememberRecentLookups, true)
        }
        set {
            AppDefaults.set(.rememberRecentLookups, newValue)
            if !newValue {
                InspectionHistoryManager.shared.removeAll()
            }
        }
    }

    var showTips: Bool {
        get {
            return AppDefaults.get(.showTips, true)
        }
        set {
            AppDefaults.set(.showTips, newValue)
        }
    }

    var getHttpHeaders: Bool {
        get {
            return AppDefaults.get(.getHttpHeaders, true)
        }
        set {
            AppDefaults.set(.getHttpHeaders, newValue)
        }
    }

    var queryOcsp: Bool {
        get {
            return AppDefaults.get(.queryOcsp, false)
        }
        set {
            AppDefaults.set(.queryOcsp, newValue)
        }
    }

    var checkCrl: Bool {
        get {
            return AppDefaults.get(.checkCrl, true)
        }
        set {
            AppDefaults.set(.checkCrl, newValue)
        }
    }

    var showFingerprintMd5: Bool {
        get {
            return AppDefaults.get(.showFingerprintMd5, false)
        }
        set {
            AppDefaults.set(.showFingerprintMd5, newValue)
        }
    }

    var showFingerprintSha1: Bool {
        get {
            return AppDefaults.get(.showFingerprintSha1, true)
        }
        set {
            AppDefaults.set(.showFingerprintSha1, newValue)
        }
    }

    var showFingerprintSha256: Bool {
        get {
            return AppDefaults.get(.showFingerprintSha256, true)
        }
        set {
            AppDefaults.set(.showFingerprintSha256, newValue)
        }
    }

    var showFingerprintSha512: Bool {
        get {
            return AppDefaults.get(.showFingerprintSha512, false)
        }
        set {
            AppDefaults.set(.showFingerprintSha512, newValue)
        }
    }

    var cryptoEngine: CryptoEngine {
        get {
            return CryptoEngine(rawValue: AppDefaults.get(.cryptoEngine, CryptoEngine.NetworkFramework.rawValue)) ?? .NetworkFramework
        }
        set {
            AppDefaults.set(.cryptoEngine, newValue.rawValue)
        }
    }

    var ipVersion: IPVersion {
        get {
            return IPVersion(rawValue: AppDefaults.get(.ipVersion, IPVersion.Automatic.rawValue)) ?? .Automatic
        }
        set {
            AppDefaults.set(.ipVersion, newValue.rawValue)
        }
    }

    var preferredCiphers: String {
        get {
            return AppDefaults.get(.preferredCiphers, "HIGH:!aNULL:!MD5:!RC4")
        }
        set {
            AppDefaults.set(.preferredCiphers, newValue)
        }
    }

    var contactNagDismissed: Bool {
        get {
            return AppDefaults.get(.contactNagDismissed, false)
        }
        set {
            AppDefaults.set(.contactNagDismissed, newValue)
        }
    }

    var advancedSettingsNagDismissed: Bool {
        get {
            return AppDefaults.get(.advancedSettingsNagDismissed, false)
        }
        set {
            AppDefaults.set(.advancedSettingsNagDismissed, newValue)
        }
    }

    var treatUnrecognizedAsTrusted: Bool {
        get {
            return AppDefaults.get(.treatUnrecognizedAsTrusted, true)
        }
        set {
            AppDefaults.set(.treatUnrecognizedAsTrusted, newValue)
        }
    }

    var appLanguage: SupportedLanguages {
        get {
            return SupportedLanguages(rawValue: AppDefaults.get(.appLanguage, SupportedLanguages.English.rawValue)) ?? .English
        }
        set {
            AppDefaults.set(.appLanguage, newValue.rawValue)
        }
    }

    var inspectTimeout: Int {
        get {
            return AppDefaults.get(.inspectTimeout, 10)
        }
        set {
            AppDefaults.set(.inspectTimeout, newValue)
        }
    }

    var verboseLogging: Bool = false
}
