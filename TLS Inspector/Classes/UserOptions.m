#import "UserOptions.h"
@import CertificateKit;

@interface UserOptions ()

@end

@implementation UserOptions

static UserOptions * _instance;

#define KEY_FIRST_RUN_COMPLETE @"first_run_complete"
#define KEY_REMEMBER_RECENT_LOOKUPS @"remember_recent_lookups"
#define KEY_USE_LIGHT_THEME @"use_light_theme"
#define KEY_SHOW_TIPS @"show_tips"
#define KEY_GET_HTTP_HEADERS @"get_http_headers"
#define KEY_QUERY_OCSP @"query_ocsp"
#define KEY_CHECK_CRL @"check_crl"
#define KEY_FINGEPRINT_MD5 @"fingerprint_md5"
#define KEY_FINGEPRINT_SHA128 @"fingerprint_sha128"
#define KEY_FINGEPRINT_SHA256 @"fingerprint_sha256"
#define KEY_FINGEPRINT_SHA512 @"fingerprint_sha512"

+ (UserOptions * _Nonnull) currentOptions {
    if (!_instance) {
        _instance = [UserOptions new];
    }
    return _instance;
}

- (id _Nonnull) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

+ (void) setDefaultValues {
    NSDictionary<NSString *, id> * defaults = @{
        KEY_REMEMBER_RECENT_LOOKUPS: @YES,
        KEY_USE_LIGHT_THEME: @NO,
        KEY_SHOW_TIPS: @YES,
        KEY_GET_HTTP_HEADERS: @YES,
        KEY_QUERY_OCSP: @YES,
        KEY_CHECK_CRL: @NO,
        KEY_FINGEPRINT_MD5: @NO,
        KEY_FINGEPRINT_SHA128: @YES,
        KEY_FINGEPRINT_SHA256: @YES,
        KEY_FINGEPRINT_SHA512: @NO,
    };
    
    for (NSString * key in defaults.allKeys) {
        if ([AppDefaults valueForKey:key] == nil) {
            [AppDefaults setValue:defaults[key] forKey:key];
        }
    }
}

- (BOOL) firstRunCompleted {
    return [AppDefaults boolForKey:KEY_FIRST_RUN_COMPLETE];
}

- (void) setFirstRunCompleted:(BOOL)firstRunCompleted {
    [AppDefaults setBool:firstRunCompleted forKey:KEY_FIRST_RUN_COMPLETE];
}

- (BOOL) rememberRecentLookups {
    return [AppDefaults boolForKey:KEY_REMEMBER_RECENT_LOOKUPS];
}

- (void) setRememberRecentLookups:(BOOL)rememberRecentLookups {
    [AppDefaults setBool:rememberRecentLookups forKey:KEY_REMEMBER_RECENT_LOOKUPS];
}

- (BOOL) useLightTheme {
    return [AppDefaults boolForKey:KEY_USE_LIGHT_THEME];
}

- (void) setUseLightTheme:(BOOL)useLightTheme {
    [AppDefaults setBool:useLightTheme forKey:KEY_USE_LIGHT_THEME];
}

- (BOOL) showTips {
    return [AppDefaults boolForKey:KEY_SHOW_TIPS];
}

- (void) setShowTips:(BOOL)showTips {
    [AppDefaults setBool:showTips forKey:KEY_SHOW_TIPS];
}

- (BOOL) getHTTPHeaders {
    return [AppDefaults boolForKey:KEY_GET_HTTP_HEADERS];
}

- (void) setGetHTTPHeaders:(BOOL)getHTTPHeaders {
    [AppDefaults setBool:getHTTPHeaders forKey:KEY_GET_HTTP_HEADERS];
}

- (BOOL) queryOCSP {
    return [AppDefaults boolForKey:KEY_QUERY_OCSP];
}

- (void) setQueryOCSP:(BOOL)queryOCSP {
    [AppDefaults setBool:queryOCSP forKey:KEY_QUERY_OCSP];
}

- (BOOL) checkCRL {
    return [AppDefaults boolForKey:KEY_CHECK_CRL];
}

- (void) setCheckCRL:(BOOL)checkCRL {
    [AppDefaults setBool:checkCRL forKey:KEY_CHECK_CRL];
}

- (void) setVerboseLogging:(BOOL)verboseLogging {
    _verboseLogging = verboseLogging;

    if (verboseLogging) {
        [CertificateKit setLoggingLevel:CKLoggingLevelDebug];
        self.inspectionsWithVerboseLogging = 0;
    } else {
        [CertificateKit setLoggingLevel:CKLoggingLevelInfo];
    }
}

- (void) setInspectionsWithVerboseLogging:(NSUInteger)inspectionsWithVerboseLogging {
    _inspectionsWithVerboseLogging = inspectionsWithVerboseLogging;
}

- (BOOL) showFingerprintMD5 {
    return [AppDefaults boolForKey:KEY_FINGEPRINT_MD5];
}

- (void) setShowFingerprintMD5:(BOOL)showFingerprintMD5 {
    [AppDefaults setBool:showFingerprintMD5 forKey:KEY_FINGEPRINT_MD5];
}

- (BOOL) showFingerprintSHA128 {
    return [AppDefaults boolForKey:KEY_FINGEPRINT_SHA128];
}

- (void) setShowFingerprintSHA128:(BOOL)showFingerprintSHA128 {
    [AppDefaults setBool:showFingerprintSHA128 forKey:KEY_FINGEPRINT_SHA128];
}

- (BOOL) showFingerprintSHA256 {
    return [AppDefaults boolForKey:KEY_FINGEPRINT_SHA256];
}

- (void) setShowFingerprintSHA256:(BOOL)showFingerprintSHA256 {
    [AppDefaults setBool:showFingerprintSHA256 forKey:KEY_FINGEPRINT_SHA256];
}

- (BOOL) showFingerprintSHA512 {
    return [AppDefaults boolForKey:KEY_FINGEPRINT_SHA512];
}

- (void) setShowFingerprintSHA512:(BOOL)showFingerprintSHA512 {
    [AppDefaults setBool:showFingerprintSHA512 forKey:KEY_FINGEPRINT_SHA512];
}

@end
