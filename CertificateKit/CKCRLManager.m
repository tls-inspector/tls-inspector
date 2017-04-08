//
//  CKCRLManager.m
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

#import "CKCRLManager.h"

@interface CKCRLManager ()

@property (strong, nonatomic) NSFileManager * fs;
@property (strong, nonatomic) NSString * crlCachePath;
@property (nonatomic) NSTimeInterval crlCacheLifetime;

@end

@implementation CKCRLManager

static CKCRLManager * _instance;
static NSDictionary<NSString *, id> * crlCache;

#define CRL_CACHE_VERSION @"1"
#define CRL_CACHE_KEY @"__crl_cache_version"
#define CRL_CACHE_CACHED_KEY @"cached"
#define CRL_CACHE_DATA_KEY @"data"
#define rightNow [NSNumber numberWithInteger:time(0)]

+ (CKCRLManager * _Nonnull) sharedInstance {
    if (!_instance) {
        _instance = [CKCRLManager new];
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
        [self unloadCRLCache];
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

- (void) unloadCRLCache {
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

@end
