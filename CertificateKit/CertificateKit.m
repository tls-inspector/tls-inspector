//
//  CertificateKit.m
//
//  LGPLv3
//
//  Copyright (c) 2018 Ian Spence
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

#import <CertificateKit/CertificateKit.h>
#import <openssl/opensslv.h>
#import <openssl/ssl.h>
#import <curl/curlver.h>

@implementation CertificateKit

+ (void) OpenSSLInit {
    OPENSSL_init_ssl(0, NULL);
    OPENSSL_init_crypto(0, NULL);
}

+ (NSString *) opensslVersion {
    NSString * version = [NSString stringWithUTF8String:OPENSSL_VERSION_TEXT]; // OpenSSL <version> ...
    NSArray<NSString *> * versionComponents = [version componentsSeparatedByString:@" "];
    return versionComponents[1];
}

+ (NSString *) libcurlVersion {
    return [NSString stringWithUTF8String:LIBCURL_VERSION];
}

+ (BOOL) isProxyConfigured {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFString = (const CFStringRef)CFDictionaryGetValue(proxySettings, (const void*)kCFNetworkProxiesHTTPProxy);
    NSString * proxyString = (__bridge NSString *)(proxyCFString);
    BOOL usingProxy = proxyString != nil && proxyString.length > 0;

    CFRelease(proxySettings);
    return usingProxy;
}

+ (NSString *) defaultCiphersuite {
    return @"HIGH:!aNULL:!MD5:!RC4";
}

@end
