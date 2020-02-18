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
private let KEY_USE_OPENSSL = "use_openssl"
private let KEY_PREFERRED_CIPHERS = "preferred_ciphers"
private let KEY_CONTACT_NAG_DISMISSED = "contact_nag_dismissed"
private let KEY_ADVANCED_SETTINGS_NAG_DISMISSED = "advanced_settings_nag_dismissed"
// swiftlint:enable identifier_name

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
        KEY_USE_OPENSSL: false,
        KEY_PREFERRED_CIPHERS: defaultOpenSSLCiphers,
        KEY_CONTACT_NAG_DISMISSED: false,
        KEY_ADVANCED_SETTINGS_NAG_DISMISSED: false,
    ]
    private static var _verboseLogging = false
    private static var _inspectionsWithVerboseLogging = 0

    static func loadDefaults() {
        for key in defaults.keys {
            if AppDefaults.value(forKey: key) == nil {
                AppDefaults.set(defaults[key], forKey: key)
            }
        }
    }

    static var firstRunCompleted: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FIRST_RUN_COMPLETE)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FIRST_RUN_COMPLETE)
        }
    }
    static var rememberRecentLookups: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_REMEMBER_RECENT_LOOKUPS)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_REMEMBER_RECENT_LOOKUPS)
        }
    }
    static var useLightTheme: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_USE_LIGHT_THEME)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_USE_LIGHT_THEME)
        }
    }
    static var showTips: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_SHOW_TIPS)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_SHOW_TIPS)
        }
    }
    static var getHTTPHeaders: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_GET_HTTP_HEADERS)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_GET_HTTP_HEADERS)
        }
    }
    static var queryOCSP: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_QUERY_OCSP)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_QUERY_OCSP)
        }
    }
    static var checkCRL: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_CHECK_CRL)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_CHECK_CRL)
        }
    }
    static var showFingerprintMD5: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_MD5)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_MD5)
        }
    }
    static var showFingerprintSHA128: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_SHA128)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_SHA128)
        }
    }
    static var showFingerprintSHA256: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_SHA256)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_SHA256)
        }
    }
    static var showFingerprintSHA512: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_FINGEPRINT_SHA512)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_FINGEPRINT_SHA512)
        }
    }
    static var useOpenSSL: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_USE_OPENSSL)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_USE_OPENSSL)
        }
    }
    static var preferredCiphers: String {
        get {
            return AppDefaults.string(forKey: KEY_PREFERRED_CIPHERS) ?? defaultOpenSSLCiphers
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_PREFERRED_CIPHERS)
        }
    }
    static var contactNagDismissed: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_CONTACT_NAG_DISMISSED)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_CONTACT_NAG_DISMISSED)
        }
    }
    static var advancedSettingsNagDismissed: Bool {
        get {
            return AppDefaults.bool(forKey: KEY_ADVANCED_SETTINGS_NAG_DISMISSED)
        }
        set {
            AppDefaults.set(newValue, forKey: KEY_ADVANCED_SETTINGS_NAG_DISMISSED)
        }
    }

    // Verbose Logging is a special case and not actually stored in the user defaults
    static var verboseLogging: Bool {
        get {
            return _verboseLogging
        }
        set {
            _verboseLogging = newValue
        }
    }
    static var inspectionsWithVerboseLogging: Int {
        get {
            return _inspectionsWithVerboseLogging
        }
        set {
            _inspectionsWithVerboseLogging = newValue
        }
    }
}
