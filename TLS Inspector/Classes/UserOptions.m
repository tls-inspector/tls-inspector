#import "UserOptions.h"

@interface UserOptions ()

@end

@implementation UserOptions

static UserOptions * _instance;

#define KEY_REMEMBER_RECENT_LOOKUPS @"remember_recent_lookups"
#define KEY_USE_LIGHT_THEME @"use_light_theme"
#define KEY_SHOW_TIPS @"show_tips"
#define KEY_QUERY_OCSP @"query_ocsp"
#define KEY_CHECK_CRL @"check_crl"

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
        KEY_QUERY_OCSP: @YES,
        KEY_CHECK_CRL: @NO,
    };
    
    for (NSString * key in defaults.allKeys) {
        if ([AppDefaults valueForKey:key] == nil) {
            [AppDefaults setValue:defaults[key] forKey:key];
        }
    }
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

@end
