//
//  TrustedFingerprints.m
//  Certificate Inspector
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
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

#import "TrustedFingerprints.h"
#import <SSKeychain/SSKeychain.h>
#import <CommonCrypto/CommonDigest.h>

@interface TrustedFingerprints ()

@property (strong, nonatomic) NSString * checksum;
@property (strong, nonatomic) NSDictionary<NSString *, NSDictionary *> * fingerprints;
@property (strong, nonatomic) NSString * filePath;

@end

@implementation TrustedFingerprints

static id _instance;
static NSString * CHECKSUM_URL      = @"https://raw.githubusercontent.com/certificate-helper/Fingerprints/master/Checksum";
static NSString * FINGERPRINTS_URL  = @"https://raw.githubusercontent.com/certificate-helper/Fingerprints/master/Fingerprints.plist";
static NSString * FINGERPRINTS_FILE = @"Fingerprints.plist";

static NSString * KEYCHAIN_SERVICE = @"Certificate-Inspector";
static NSString * KEYCHAIN_ACCOUNT = @"Trusted-Certificates";

- (id) init {
    if (_instance == nil) {
        TrustedFingerprints * fingerprints = [super init];
        fingerprints.checksum = [SSKeychain passwordForService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT];
        fingerprints.checksum = [fingerprints.checksum stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        fingerprints.filePath = [documentsDirectory stringByAppendingPathComponent:FINGERPRINTS_FILE];
        [NSThread detachNewThreadSelector:@selector(checkForUpdates) toTarget:fingerprints withObject:nil];
        _instance = fingerprints;
    }
    return _instance;
}

+ (TrustedFingerprints *) sharedInstance {
    if (!_instance) {
        _instance = [TrustedFingerprints new];
    }
    return _instance;
}

- (void) checkForUpdates {
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:CHECKSUM_URL]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:5.0];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask = [session
     dataTaskWithRequest:request
     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSString * remoteChecksum = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            remoteChecksum = [remoteChecksum stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if ([self.checksum isEqualToString:remoteChecksum]) {
                d(@"No fingerprint updates needed.");
                if ([self verifyLocalFingerprints]) {
                    [self readLocalFingerprints];
                } else {
                    NSFileManager * manager = [NSFileManager defaultManager];
                    [manager removeItemAtPath:self.filePath error:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTrustedFingerprintLocalSecFailure object:nil];
                    [SSKeychain setPassword:@"" forService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT];
                }
            } else {
                self.checksum = remoteChecksum;
                [SSKeychain setPassword:remoteChecksum forService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT];
                d(@"A new version of fingerprint data is ready for download");
                [self updateFingerprints];
            }
        }
    }];
    [dataTask resume];
}

- (BOOL) verifyLocalFingerprints {
    NSData * fileData = [NSData dataWithContentsOfFile:self.filePath];
    if (fileData) {
        NSString * localChecksum = [self sha256Hash:fileData];
        BOOL verified = [localChecksum isEqualToString:self.checksum];
        if (verified) {
            d(@"Local fingerprint data verified");
        } else {
            d(@"Local fingerprint data not verified!");
        }
        d(@"Expected checksum:   %@", self.checksum);
        d(@"Calculated checksum: %@", localChecksum);
        return verified;
    }
    d(@"No local fingerprint cache available.");
    [self updateFingerprints];
    return NO;
}

- (NSString *) sha256Hash:(NSData *)input {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([input bytes], (CC_LONG)[input length], result);
    
    NSMutableString * hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x",result[i]];
    }
    return hash;
}

- (void) updateFingerprints {
    d(@"Downloading fingerprint data");
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:FINGERPRINTS_URL]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:5.0];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask = [session
     dataTaskWithRequest:request
     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            [data writeToFile:self.filePath atomically:YES];
            if ([self verifyLocalFingerprints]) {
                [self readLocalFingerprints];
            } else {
                NSFileManager * manager = [NSFileManager defaultManager];
                [manager removeItemAtPath:self.filePath error:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTrustedFingerprintRemoteSecFailure object:nil];
                [SSKeychain setPassword:@"" forService:KEYCHAIN_SERVICE account:KEYCHAIN_ACCOUNT];
            }
        }
    }];
    [dataTask resume];
}

- (void) readLocalFingerprints {
    NSData * fileData = [NSData dataWithContentsOfFile:self.filePath];
    NSString * error;
    NSPropertyListFormat format;
    NSDictionary * fingerprints = [NSPropertyListSerialization
                                   propertyListFromData:fileData
                                   mutabilityOption:NSPropertyListImmutable
                                   format:&format
                                   errorDescription:&error];
    if (!error) {
        d(@"Local fingerprint data updated");
        self.fingerprints = fingerprints;
    }
}

- (NSDictionary<NSString *, id> * _Nullable) dataForFingerprint:(NSString * _Nonnull)sha1fingerprint {
    if (self.fingerprints) {
        return [self.fingerprints objectForKey:sha1fingerprint];
    }
    return nil;
}

@end
