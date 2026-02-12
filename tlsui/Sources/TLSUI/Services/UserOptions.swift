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
import Localization

private enum AppDefaultsKeys: String, CaseIterable {
    case verboseLogging = "verbose_logging"
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
    nonisolated(unsafe) private static let defaultValues: [AppDefaultsKeys: Any] = [
        .verboseLogging: true,
        .firstRunComplete: false,
        .rememberRecentLookups: true,
        .showTips: true,
        .getHttpHeaders: true,
        .queryOcsp: false,
        .checkCrl: true,
        .showFingerprintMd5: false,
        .showFingerprintSha1: true,
        .showFingerprintSha256: true,
        .showFingerprintSha512: false,
        .preferredCiphers: "HIGH:!aNULL:!MD5:!RC4",
        .advancedSettingsNagDismissed: false,
        .cryptoEngine: CryptoEngine.NetworkFramework.rawValue,
        .ipVersion: IPVersion.Automatic.rawValue,
        .optionsSchemaVersion: "",
        .treatUnrecognizedAsTrusted: true,
        .appLanguage: SupportedLanguages.English.rawValue,
        .inspectTimeout: 10,
    ]

    public static func get<T>(_ key: AppDefaultsKeys) -> T {
        let r = s.value(forKey: key.rawValue) as? T
        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Get AppDefault: \(key) = \(String(describing: r))")
        // swiftlint:disable force_cast
        return r ?? AppDefaults.defaultValues[key] as! T
        // swiftlint:enable force_cast
    }

    public static func set(_ key: AppDefaultsKeys, _ value: Any) {
        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Set AppDefault: \(key) = \(value)")
        return s.set(value, forKey: key.rawValue)
    }

    public static func reset() {
        for key in AppDefaultsKeys.allCases {
            set(key, AppDefaults.defaultValues[key])
        }
    }
}

@MainActor
public final class UserOptions {
    public static let current = UserOptions()

    public func reset() {
        AppDefaults.reset()
    }

    public var firstRunComplete: Bool {
        get {
            return AppDefaults.get(.firstRunComplete)
        }
        set {
            AppDefaults.set(.firstRunComplete, newValue)
        }
    }

    public var rememberRecentLookups: Bool {
        get {
            return AppDefaults.get(.rememberRecentLookups)
        }
        set {
            AppDefaults.set(.rememberRecentLookups, newValue)
        }
    }

    public var showTips: Bool {
        get {
            return AppDefaults.get(.showTips)
        }
        set {
            AppDefaults.set(.showTips, newValue)
        }
    }

    public var getHttpHeaders: Bool {
        get {
            return AppDefaults.get(.getHttpHeaders)
        }
        set {
            AppDefaults.set(.getHttpHeaders, newValue)
        }
    }

    public var queryOcsp: Bool {
        get {
            return AppDefaults.get(.queryOcsp)
        }
        set {
            AppDefaults.set(.queryOcsp, newValue)
        }
    }

    public var checkCrl: Bool {
        get {
            return AppDefaults.get(.checkCrl)
        }
        set {
            AppDefaults.set(.checkCrl, newValue)
        }
    }

    public var showFingerprintMd5: Bool {
        get {
            return AppDefaults.get(.showFingerprintMd5)
        }
        set {
            AppDefaults.set(.showFingerprintMd5, newValue)
        }
    }

    public var showFingerprintSha1: Bool {
        get {
            return AppDefaults.get(.showFingerprintSha1)
        }
        set {
            AppDefaults.set(.showFingerprintSha1, newValue)
        }
    }

    public var showFingerprintSha256: Bool {
        get {
            return AppDefaults.get(.showFingerprintSha256)
        }
        set {
            AppDefaults.set(.showFingerprintSha256, newValue)
        }
    }

    public var showFingerprintSha512: Bool {
        get {
            return AppDefaults.get(.showFingerprintSha512)
        }
        set {
            AppDefaults.set(.showFingerprintSha512, newValue)
        }
    }

    public var cryptoEngine: CryptoEngine {
        get {
            return CryptoEngine(rawValue: AppDefaults.get(.cryptoEngine)) ?? .NetworkFramework
        }
        set {
            AppDefaults.set(.cryptoEngine, newValue.rawValue)
        }
    }

    public var ipVersion: IPVersion {
        get {
            return IPVersion(rawValue: AppDefaults.get(.ipVersion)) ?? .Automatic
        }
        set {
            AppDefaults.set(.ipVersion, newValue.rawValue)
        }
    }

    public var preferredCiphers: String {
        get {
            return AppDefaults.get(.preferredCiphers)
        }
        set {
            AppDefaults.set(.preferredCiphers, newValue)
        }
    }

    public var advancedSettingsNagDismissed: Bool {
        get {
            return AppDefaults.get(.advancedSettingsNagDismissed)
        }
        set {
            AppDefaults.set(.advancedSettingsNagDismissed, newValue)
        }
    }

    public var treatUnrecognizedAsTrusted: Bool {
        get {
            return AppDefaults.get(.treatUnrecognizedAsTrusted)
        }
        set {
            AppDefaults.set(.treatUnrecognizedAsTrusted, newValue)
        }
    }

    public var appLanguage: SupportedLanguages {
        get {
            return SupportedLanguages(rawValue: AppDefaults.get(.appLanguage)) ?? .English
        }
        set {
            AppDefaults.set(.appLanguage, newValue.rawValue)
        }
    }

    public var inspectTimeout: Int {
        get {
            return AppDefaults.get(.inspectTimeout)
        }
        set {
            AppDefaults.set(.inspectTimeout, newValue)
        }
    }

    public var verboseLogging: Bool {
        get {
            return AppDefaults.get(.verboseLogging)
        }
        set {
            AppDefaults.set(.verboseLogging, newValue)
            if newValue {
                LogWriter.shared.setLevel(.Debug)
            } else {
                LogWriter.shared.setLevel(.Error)
            }
        }
    }
}
