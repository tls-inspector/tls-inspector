//
//  CHCRLManager.m
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
//  https://github.com/ecnepsnai/CHCertificate
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

#import "CHCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/ossl_typ.h>
#include <openssl/x509v3.h>

@interface CHCRLManager () {
    void (^finishedBlock)(BOOL, NSError *);
    NSUInteger crlsRemaining;
    CHCertificate * certificate;
}

@property (strong, nonatomic) NSFileManager * fs;
@property (strong, nonatomic) NSString * crlCachePath;

@end

@implementation CHCRLManager

static CHCRLManager * _instance;
static NSDictionary<NSString *, id> * crlCache;

#define CRL_CACHE_VERSION @"1"
#define CRL_CACHE_KEY @"__crl_cache_version"
#define CRL_CACHE_CACHED_KEY @"cached"
#define CRL_CACHE_DATA_KEY @"data"
#define rightNow [NSNumber numberWithInteger:time(0)]

+ (CHCRLManager * _Nonnull) sharedInstance {
    if (!_instance) {
        _instance = [CHCRLManager new];
    }
    return _instance;
}

- (id _Nonnull) init {
    if (!_instance) {
        _instance = [super init];
        _instance.fs = [NSFileManager new];
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _instance.crlCachePath = [path stringByAppendingPathComponent:@"crl_cache.plist"];
        _instance.crlCacheLifetime = 172800; // 2 days
    }
    return _instance;
}

- (NSString *) crlCachePath {
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"crl_cache.plist"];
    return path;
}

- (void) loadCRLCache {
    if (crlCache) {
        [self unloacCRLCache];
    }

    if ([self.fs fileExistsAtPath:self.crlCachePath]) {
        crlCache = [[NSDictionary alloc] initWithContentsOfFile:self.crlCachePath];
    } else {
        crlCache = @{
                     CRL_CACHE_KEY: CRL_CACHE_VERSION
                     };
    }

    if (![[crlCache objectForKey:CRL_CACHE_KEY] isEqualToString:CRL_CACHE_VERSION]) {
        // Invalidate cache
        crlCache = nil;
        [self.fs removeItemAtPath:self.crlCachePath error:nil];
        [self loadCRLCache];
    }
}

- (void) unloacCRLCache {
    if (!crlCache) {
        return;
    }

    [crlCache writeToFile:self.crlCachePath atomically:YES];
    crlCache = nil;
}

- (void) addResponseToCache:(NSString *)key data:(NSDictionary<NSString *, id> *)data {
    NSMutableDictionary * newCache = [crlCache mutableCopy];
    [newCache setValue:data forKey:key];
    crlCache = [NSDictionary dictionaryWithDictionary:newCache];
    newCache = nil;
}

- (void) getCRL:(NSURL *)crl finished:(void (^)(NSData * data, NSError * error))finished {
    NSDictionary<NSString *, id> * cache = [crlCache objectForKey:[crl absoluteString]];
    if (cache) {
        NSInteger cachedDate = [[cache objectForKey:CRL_CACHE_CACHED_KEY] integerValue];
        NSInteger now = time(0);
        NSInteger difference = now - cachedDate;
        if (difference <= self.crlCacheLifetime) {
            NSLog(@"Using CRL data from cache");
            finished([cache objectForKey:CRL_CACHE_DATA_KEY], nil);
            return;
        }
    }
    
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForResource = 5.0;
    NSURLSession * urlSession = [NSURLSession sessionWithConfiguration:config];
    NSLog(@"Fetching CRL data from server");
    [[urlSession
      dataTaskWithURL:crl
      completionHandler:^(NSData * _Nullable data,
                          NSURLResponse * _Nullable response,
                          NSError * _Nullable error) {
          NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
          if (!error && httpResponse.statusCode == 200) {
              NSDictionary<NSString *, id> * cache = @{
                                                       CRL_CACHE_CACHED_KEY: rightNow,
                                                       CRL_CACHE_DATA_KEY: data
                                                       };
              [self addResponseToCache:[crl absoluteString] data:cache];
              finished(data, nil);
          } else {
              finished(nil, error ?: [NSError errorWithDomain:@"HTTP" code:httpResponse.statusCode userInfo:nil]);
          }
      }] resume];
}

- (void) isCertificateRevoked:(CHCertificate *)cert finished:(void (^)(BOOL revoked, NSError * error))finished {
    finishedBlock = finished;
    certificate = cert;
    [self loadCRLCache];
    
    
    
    distributionPoints * crls = [cert crlDistributionPoints];
    crlsRemaining = crls.count;
    
    for (NSURL * url in crls) {
        [self getCRL:url finished:^(NSData *data, NSError *error) {
            if (error) {
                finished(NO, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    crlsRemaining --;
                    [self crlDownloaded:crls];
                });
            }
        }];
    }
}

- (void) crlDownloaded:(distributionPoints *)crls {
    if (crlsRemaining == 0) {
        X509_CRL * crl;
        NSData * crlData = [[crlCache objectForKey:[[crls objectAtIndex:0] absoluteString]] objectForKey:CRL_CACHE_DATA_KEY];
        const unsigned char * bytes = (const unsigned char *)[crlData bytes];
        crl = d2i_X509_CRL(NULL, &bytes, [crlData length]);
        struct x509_revoked_st * revoked;
        const ASN1_INTEGER * serial = X509_get0_serialNumber(certificate.X509Certificate);
        X509_CRL_get0_by_serial(crl, &revoked, (ASN1_INTEGER *)serial);
        if (revoked->reason == CRL_REASON_REMOVE_FROM_CRL) {
            
        }
    }
}

@end
