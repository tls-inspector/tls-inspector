#import "CKServerInfo.h"
#include <curl/curl.h>

@interface CKServerInfo()

@property (strong, nonatomic) NSDictionary<NSString *, id> * cachedSecurityHeaders;

@end

@implementation CKServerInfo

- (NSDictionary<NSString *, id> *)securityHeaders {
    if (self.cachedSecurityHeaders != nil) {
        return self.cachedSecurityHeaders;
    }

    NSMutableDictionary<NSString *, id> * sHeaders = [NSMutableDictionary new];

    // Shoutout to Scott Helme for putting together this list! 🇬🇧
    // https://securityheaders.io, https://scotthelme.co.uk/
    NSArray<NSString *> * SECURE_HEADERS = @[@"Content-Security-Policy", @"Public-Key-Pins", @"Strict-Transport-Security", @"X-Frame-Options", @"X-XSS-Protection", @"X-Content-Type-Options", @"Referrer-Policy"];

    NSArray<NSString *> * headerKeys = self.headers.allKeys;
    for (NSString * secureHeaderKey in SECURE_HEADERS) {
        NSString * actualHeaderKey = [self array:headerKeys ContainsCaseInsensitiveString:secureHeaderKey];
        if (actualHeaderKey != nil) {
            NSString * value = [self.headers objectForKey:actualHeaderKey];
            [sHeaders setValue:value forKey:secureHeaderKey];
        } else {
            [sHeaders setValue:@NO forKey:secureHeaderKey];
        }
    }

    self.cachedSecurityHeaders = sHeaders;
    return sHeaders;
}

- (NSString *) array:(NSArray<NSString *> *)array ContainsCaseInsensitiveString:(NSString *)needle {
    for (NSString * elm in array) {
        NSString * lowercaseHaystack = [elm lowercaseString];
        NSString * lowercaseNeedle = [needle lowercaseString];
        if ([elm isEqualToString:needle] || [lowercaseHaystack isEqualToString:lowercaseNeedle]) {
            return elm;
        }
    }

    return nil;
}

@end
