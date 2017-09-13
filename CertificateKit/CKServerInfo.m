#import "CKServerInfo.h"
#include <curl/curl.h>

@interface CKServerInfo()

@property (strong, nonatomic) NSDictionary<NSString *, NSString *> * cachedSecurityHeaders;

@end

@implementation CKServerInfo

- (NSDictionary<NSString *,NSString *> *)securityHeaders {
    if (self.cachedSecurityHeaders != nil) {
        return self.cachedSecurityHeaders;
    }

    NSMutableDictionary<NSString *, NSString *> * sHeaders = [NSMutableDictionary new];

    // Shoutout to Scott Helme for putting together this list! 🇬🇧
    // https://securityheaders.io, https://scotthelme.co.uk/
    NSArray<NSString *> * SECURE_HEADERS = @[@"Content-Security-Policy", @"Public-Key-Pins", @"Strict-Transport-Security", @"X-Frame-Options", @"X-XSS-Protection", @"X-Content-Type-Options", @"Referrer-Policy"];

    for (NSString * sHeaderKey in SECURE_HEADERS) {
        NSString * value = [self.headers objectForKey:sHeaderKey];
        if (value != nil) {
            [sHeaders setValue:value forKey:sHeaderKey];
        }
    }

    self.cachedSecurityHeaders = sHeaders;
    return sHeaders;
}

@end
