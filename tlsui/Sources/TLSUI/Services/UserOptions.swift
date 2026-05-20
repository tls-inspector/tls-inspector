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

public enum AppDefaultsKeys: String, CaseIterable {
    case verboseLogging = "verbose_logging"
    case firstRunComplete = "first_run_complete"
    case rememberRecentLookups = "remember_recent_lookups"
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
public final class UserOptions: ObservableObject {
    public static func bootstrapLanguage() {
        let selectedLanguage = SupportedLanguages.init(rawValue: AppDefaults.get(.appLanguage)) ?? .English
        currentLanguage = selectedLanguage
    }

    public init() {
        verboseLogging = AppDefaults.get(.verboseLogging)
        firstRunComplete = AppDefaults.get(.firstRunComplete)
        rememberRecentLookups = AppDefaults.get(.rememberRecentLookups)
        getHttpHeaders = AppDefaults.get(.getHttpHeaders)
        queryOcsp = AppDefaults.get(.queryOcsp)
        checkCrl = AppDefaults.get(.checkCrl)
        showFingerprintMd5 = AppDefaults.get(.showFingerprintMd5)
        showFingerprintSha1 = AppDefaults.get(.showFingerprintSha1)
        showFingerprintSha256 = AppDefaults.get(.showFingerprintSha256)
        showFingerprintSha512 = AppDefaults.get(.showFingerprintSha512)
        preferredCiphers = AppDefaults.get(.preferredCiphers)
        advancedSettingsNagDismissed = AppDefaults.get(.advancedSettingsNagDismissed)
        cryptoEngine = CryptoEngine.init(rawValue: AppDefaults.get(.cryptoEngine)) ?? .NetworkFramework
        ipVersion = IPVersion.init(rawValue: AppDefaults.get(.ipVersion)) ?? .Automatic
        let selectedLanguage = SupportedLanguages.init(rawValue: AppDefaults.get(.appLanguage)) ?? .English
        appLanguage = selectedLanguage
        treatUnrecognizedAsTrusted = AppDefaults.get(.treatUnrecognizedAsTrusted)
        inspectTimeout = AppDefaults.get(.inspectTimeout)
        currentLanguage = selectedLanguage
    }

    @Published public var verboseLogging: Bool {
        didSet {
            AppDefaults.set(.verboseLogging, verboseLogging)

            if verboseLogging {
                LogWriter.shared.setLevel(.Debug)
            } else {
                LogWriter.shared.setLevel(.Error)
            }
        }
    }

    @Published public var firstRunComplete: Bool {
        didSet { AppDefaults.set(.firstRunComplete, firstRunComplete) }
    }

    @Published public var rememberRecentLookups: Bool {
        didSet { AppDefaults.set(.rememberRecentLookups, rememberRecentLookups) }
    }

    @Published public var getHttpHeaders: Bool {
        didSet { AppDefaults.set(.getHttpHeaders, getHttpHeaders) }
    }

    @Published public var queryOcsp: Bool {
        didSet { AppDefaults.set(.queryOcsp, queryOcsp) }
    }

    @Published public var checkCrl: Bool {
        didSet { AppDefaults.set(.checkCrl, checkCrl) }
    }

    @Published public var showFingerprintMd5: Bool {
        didSet { AppDefaults.set(.showFingerprintMd5, showFingerprintMd5) }
    }

    @Published public var showFingerprintSha1: Bool {
        didSet { AppDefaults.set(.showFingerprintSha1, showFingerprintSha1) }
    }

    @Published public var showFingerprintSha256: Bool {
        didSet { AppDefaults.set(.showFingerprintSha256, showFingerprintSha256) }
    }

    @Published public var showFingerprintSha512: Bool {
        didSet { AppDefaults.set(.showFingerprintSha512, showFingerprintSha512) }
    }

    @Published public var preferredCiphers: String {
        didSet { AppDefaults.set(.preferredCiphers, preferredCiphers) }
    }

    @Published public var advancedSettingsNagDismissed: Bool {
        didSet { AppDefaults.set(.advancedSettingsNagDismissed, advancedSettingsNagDismissed) }
    }

    @Published public var cryptoEngine: CryptoEngine {
        didSet { AppDefaults.set(.cryptoEngine, cryptoEngine.rawValue) }
    }

    @Published public var ipVersion: IPVersion {
        didSet { AppDefaults.set(.ipVersion, ipVersion.rawValue) }
    }

    @Published public var appLanguage: SupportedLanguages {
        didSet { AppDefaults.set(.appLanguage, appLanguage.rawValue) }
    }

    @Published public var treatUnrecognizedAsTrusted: Bool {
        didSet { AppDefaults.set(.treatUnrecognizedAsTrusted, treatUnrecognizedAsTrusted) }
    }

    @Published public var inspectTimeout: Int {
        didSet { AppDefaults.set(.inspectTimeout, inspectTimeout) }
    }

    public static func reset() {
        AppDefaults.reset()
    }
}
