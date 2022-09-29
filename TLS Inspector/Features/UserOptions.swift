import Foundation

// swiftlint:disable identifier_name
private let KEY_FIRST_RUN_COMPLETE = "first_run_complete"
private let KEY_REMEMBER_RECENT_LOOKUPS = "remember_recent_lookups"
private let KEY_USE_LIGHT_THEME = "use_light_theme"
private let KEY_SHOW_TIPS = "show_tips"
private let KEY_GET_HTTP_HEADERS = "get_http_headers"
private let KEY_QUERY_OCSP = "query_ocsp"
private let KEY_CHECK_CRL = "check_crl"
private let KEY_FINGEPRINT_MD5 = "fingerprint_md5"
private let KEY_FINGEPRINT_SHA128 = "fingerprint_sha128"
private let KEY_FINGEPRINT_SHA256 = "fingerprint_sha256"
private let KEY_FINGEPRINT_SHA512 = "fingerprint_sha512"
private let KEY_PREFERRED_CIPHERS = "preferred_ciphers"
private let KEY_CONTACT_NAG_DISMISSED = "contact_nag_dismissed"
private let KEY_ADVANCED_SETTINGS_NAG_DISMISSED = "advanced_settings_nag_dismissed"
private let KEY_CRYPTO_ENGINE = "crypto_engine"
private let KEY_IP_VERSION = "use_ip_version"
private let KEY_OPTIONS_SCHEMA_VERSION = "options_schema_version"
// swiftlint:enable identifier_name

public enum CryptoEngine: String {
    case NetworkFramework = "network_framework"
    case SecureTransport = "secure_transport"
    case OpenSSL = "openssl"

    static func allValues() -> [CryptoEngine] {
        return [
            .NetworkFramework,
            .SecureTransport,
            .OpenSSL,
        ]
    }

    func intValue() -> Int {
        switch self {
        case .NetworkFramework:
            return 1
        case .SecureTransport:
            return 2
        case .OpenSSL:
            return 3
        }
    }

    static func from(int: Int) -> CryptoEngine? {
        switch int {
        case 1:
            return .NetworkFramework
        case 2:
            return .SecureTransport
        case 3:
            return .OpenSSL
        default:
            return nil
        }
    }
}

public enum IPVersion: String {
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

class UserOptions {
    private static let defaultOpenSSLCiphers = "HIGH:!aNULL:!MD5:!RC4"
    private static let defaults: [String:Any] = [
        KEY_REMEMBER_RECENT_LOOKUPS: true,
        KEY_USE_LIGHT_THEME: false,
        KEY_SHOW_TIPS: true,
        KEY_GET_HTTP_HEADERS: true,
        KEY_QUERY_OCSP: true,
        KEY_CHECK_CRL: false,
        KEY_FINGEPRINT_MD5: false,
        KEY_FINGEPRINT_SHA128: true,
        KEY_FINGEPRINT_SHA256: true,
        KEY_FINGEPRINT_SHA512: false,
        KEY_CRYPTO_ENGINE: CryptoEngine.NetworkFramework.rawValue,
        KEY_IP_VERSION: IPVersion.Automatic.rawValue,
        KEY_PREFERRED_CIPHERS: defaultOpenSSLCiphers,
        KEY_CONTACT_NAG_DISMISSED: false,
        KEY_ADVANCED_SETTINGS_NAG_DISMISSED: false,
    ]
    private static var _verboseLogging = false
    private static var _inspectionsWithVerboseLogging = 0

    static func loadDefaults() {
        for key in defaults.keys {
            if AppDefaults.value(forKey: key) == nil {
                print("Setting default value for '\(key)' to '\(defaults[key]!)'")
                AppDefaults.set(defaults[key], forKey: key)
            }
        }

        let wantedVersion = 1
        let currentVersion = (AppDefaults.value(forKey: KEY_OPTIONS_SCHEMA_VERSION) as? NSNumber)?.intValue ?? 0

        if currentVersion < wantedVersion {
            // #1 Automatically migrate eligable users to the new Network framework crypto engine
            if currentVersion < 1 {
                if AppDefaults.bool(forKey: "use_openssl") {
                    print("Migrating legacy crypto engine key. Setting \(KEY_CRYPTO_ENGINE) to \(CryptoEngine.OpenSSL.rawValue)")
                    AppDefaults.setValue(CryptoEngine.OpenSSL.rawValue, forKey: KEY_CRYPTO_ENGINE)
                } else {
                    print("Migrating legacy crypto engine key. Setting \(KEY_CRYPTO_ENGINE) to \(CryptoEngine.NetworkFramework.rawValue)")
                    AppDefaults.setValue(CryptoEngine.NetworkFramework.rawValue, forKey: KEY_CRYPTO_ENGINE)
                }
                AppDefaults.removeObject(forKey: "use_openssl")
            }

            AppDefaults.setValue(NSNumber.init(value: wantedVersion), forKey: KEY_OPTIONS_SCHEMA_VERSION)
        }
    }

    static var firstRunCompleted: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FIRST_RUN_COMPLETE)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FIRST_RUN_COMPLETE)
            LogDebug("Setting AppDefault: \(KEY_FIRST_RUN_COMPLETE) = \(newValue)")
        }
    }
    static var rememberRecentLookups: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_REMEMBER_RECENT_LOOKUPS)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_REMEMBER_RECENT_LOOKUPS)
            LogDebug("Setting AppDefault: \(KEY_REMEMBER_RECENT_LOOKUPS) = \(newValue)")
        }
    }
    static var useLightTheme: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_USE_LIGHT_THEME)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_USE_LIGHT_THEME)
            LogDebug("Setting AppDefault: \(KEY_USE_LIGHT_THEME) = \(newValue)")
        }
    }
    static var showTips: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_SHOW_TIPS)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_SHOW_TIPS)
            LogDebug("Setting AppDefault: \(KEY_SHOW_TIPS) = \(newValue)")
        }
    }
    static var getHTTPHeaders: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_GET_HTTP_HEADERS)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_GET_HTTP_HEADERS)
            LogDebug("Setting AppDefault: \(KEY_GET_HTTP_HEADERS) = \(newValue)")
        }
    }
    static var queryOCSP: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_QUERY_OCSP)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_QUERY_OCSP)
            LogDebug("Setting AppDefault: \(KEY_QUERY_OCSP) = \(newValue)")
        }
    }
    static var checkCRL: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_CHECK_CRL)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_CHECK_CRL)
            LogDebug("Setting AppDefault: \(KEY_CHECK_CRL) = \(newValue)")
        }
    }
    static var showFingerprintMD5: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_MD5)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_MD5)
            LogDebug("Setting AppDefault: \(KEY_FINGEPRINT_MD5) = \(newValue)")
        }
    }
    static var showFingerprintSHA128: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_SHA128)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_SHA128)
            LogDebug("Setting AppDefault: \(KEY_FINGEPRINT_SHA128) = \(newValue)")
        }
    }
    static var showFingerprintSHA256: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_SHA256)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_SHA256)
            LogDebug("Setting AppDefault: \(KEY_FINGEPRINT_SHA256) = \(newValue)")
        }
    }
    static var showFingerprintSHA512: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_SHA512)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_SHA512)
            LogDebug("Setting AppDefault: \(KEY_FINGEPRINT_SHA512) = \(newValue)")
        }
    }
    static var cryptoEngine: CryptoEngine {
        get {
            guard let str = AppDefaults.string(forKey: KEY_CRYPTO_ENGINE) else {
                return CryptoEngine.NetworkFramework
            }
            return CryptoEngine.init(rawValue: str) ?? .NetworkFramework
        }
        set {
            AppDefaults.set(newValue.rawValue, forKey: KEY_CRYPTO_ENGINE)
            LogDebug("Setting AppDefault: \(KEY_CRYPTO_ENGINE) = \(newValue)")
        }
    }
    static var ipVersion: IPVersion {
        get {
            guard let str = AppDefaults.string(forKey: KEY_IP_VERSION) else {
                return IPVersion.Automatic
            }
            return IPVersion.init(rawValue: str) ?? .Automatic
        }
        set {
            AppDefaults.set(newValue.rawValue, forKey: KEY_IP_VERSION)
            LogDebug("Setting AppDefault: \(KEY_IP_VERSION) = \(newValue)")
        }
    }
    static var preferredCiphers: String {
        get {
            return AppDefaults.string(forKey: KEY_PREFERRED_CIPHERS) ?? defaultOpenSSLCiphers
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_PREFERRED_CIPHERS)
            LogDebug("Setting AppDefault: \(KEY_PREFERRED_CIPHERS) = \(newValue)")
        }
    }
    static var contactNagDismissed: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_CONTACT_NAG_DISMISSED)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_CONTACT_NAG_DISMISSED)
            LogDebug("Setting AppDefault: \(KEY_CONTACT_NAG_DISMISSED) = \(newValue)")
        }
    }
    static var advancedSettingsNagDismissed: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_ADVANCED_SETTINGS_NAG_DISMISSED)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_ADVANCED_SETTINGS_NAG_DISMISSED)
            LogDebug("Setting AppDefault: \(KEY_ADVANCED_SETTINGS_NAG_DISMISSED) = \(newValue)")
        }
    }

    // Verbose Logging is a special case and not actually stored in the user defaults
    static var verboseLogging: Bool {
        get {
            return _verboseLogging
        }
        set {
            _verboseLogging = newValue
            LogDebug("Setting AppDefault: \(newValue) = \(newValue)")
        }
    }
    static var inspectionsWithVerboseLogging: Int {
        get {
            return _inspectionsWithVerboseLogging
        }
        set {
            _inspectionsWithVerboseLogging = newValue
            LogDebug("Setting AppDefault: \(newValue) = \(newValue)")
        }
    }
}
