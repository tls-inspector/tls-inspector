//
//  CKServerInfo.h
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>.

#import "CKServerInfo.h"
#include <curl/curl.h>
#include <curl/curlver.h>

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
    NSArray<NSString *> * SECURE_HEADERS = @[
        @"Content-Security-Policy",
        @"Permissions-Policy",
        @"Referrer-Policy",
        @"Strict-Transport-Security",
        @"X-Content-Type-Options",
        @"X-Frame-Options",
    ];

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
