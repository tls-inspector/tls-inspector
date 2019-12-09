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
// swiftlint:enable identifier_name

class UserOptions {
    private static var userDefaults: UserDefaults?
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
        KEY_PREFERRED_CIPHERS: "HIGH:!aNULL:!MD5:!RC4",
        KEY_CONTACT_NAG_DISMISSED: false,
    ]
    private static var _verboseLogging = false
    private static var _inspectionsWithVerboseLogging = 0

    static func loadDefaults() {
        userDefaults = UserDefaults(suiteName: "group.com.ecnepsnai.TLSISwift")
        for key in defaults.keys {
            if userDefaults?.value(forKey: key) == nil {
                userDefaults?.set(defaults[key], forKey: key)
            }
        }
    }

    static var firstRunCompleted: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_FIRST_RUN_COMPLETE) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_FIRST_RUN_COMPLETE)
        }
    }
    static var rememberRecentLookups: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_REMEMBER_RECENT_LOOKUPS) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_REMEMBER_RECENT_LOOKUPS)
        }
    }
    static var useLightTheme: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_USE_LIGHT_THEME) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_USE_LIGHT_THEME)
        }
    }
    static var showTips: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_SHOW_TIPS) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_SHOW_TIPS)
        }
    }
    static var getHTTPHeaders: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_GET_HTTP_HEADERS) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_GET_HTTP_HEADERS)
        }
    }
    static var queryOCSP: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_QUERY_OCSP) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_QUERY_OCSP)
        }
    }
    static var checkCRL: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_CHECK_CRL) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_CHECK_CRL)
        }
    }
    static var showFingerprintMD5: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_FINGEPRINT_MD5) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_FINGEPRINT_MD5)
        }
    }
    static var showFingerprintSHA128: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_FINGEPRINT_SHA128) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_FINGEPRINT_SHA128)
        }
    }
    static var showFingerprintSHA256: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_FINGEPRINT_SHA256) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_FINGEPRINT_SHA256)
        }
    }
    static var showFingerprintSHA512: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_FINGEPRINT_SHA512) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_FINGEPRINT_SHA512)
        }
    }
    static var useOpenSSL: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_USE_OPENSSL) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_USE_OPENSSL)
        }
    }
    static var preferredCiphers: String {
        get {
            return userDefaults?.string(forKey: KEY_PREFERRED_CIPHERS) ?? "HIGH:!aNULL:!MD5:!RC4"
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_PREFERRED_CIPHERS)
        }
    }
    static var contactNagDismissed: Bool {
        get {
            return userDefaults?.bool(forKey: KEY_CONTACT_NAG_DISMISSED) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: KEY_CONTACT_NAG_DISMISSED)
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
