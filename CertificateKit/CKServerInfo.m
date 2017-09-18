//
//  CKServerInfo.h
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
//  https://github.com/certificate-helper/CertificateKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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

+ (NSString * _Nonnull) libcurlVersion {
    return [NSString stringWithUTF8String:LIBCURL_VERSION];
}

@end
