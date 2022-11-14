#import "CertificateKit.h"
#import "CKMozillaRootStore.h"
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
    return proxyString != nil && proxyString.length > 0;
}

+ (NSDate * _Nullable) mozillaBundleDate {
    return CKMozillaRootStore.sharedInstance.bundleDate;
}

+ (NSString * _Nullable) mozillaBundleSHA256 {
    return CKMozillaRootStore.sharedInstance.bundleSHA256;
}

@end
