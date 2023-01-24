//
//  CKRootCACertificateBundleManager.m
//
//  LGPLv3
//
//  Copyright (c) 2022 Ian Spence
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

#import "CKRootCACertificateBundleManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <openssl/evp.h>
#import <openssl/pem.h>
#import <openssl/bio.h>
#import <openssl/err.h>

static id _instance;

@interface CKRootCACertificateBundleManager () <NSURLSessionDataDelegate, NSURLSessionDelegate>

@property (strong, nonatomic, nonnull) NSString * bundleDirectory;
@property (strong, nonatomic, nonnull) NSArray<NSString *> * bundleFiles;
@property (strong, nonatomic, nonnull) NSURLSession * urlSession;
@property (strong, nonatomic, nonnull) NSString * embeddedBundleTag;
@property (strong, nonatomic, nullable) NSString * downloadedBundleTag;
@property (strong, nonatomic, nonnull) NSDictionary<NSString *, id> * embeddedBundleMetadata;
@property (strong, nonatomic, nonnull) NSData * signingKey;
@property (nonatomic, readwrite) BOOL usingDownloadedBundles;

@property (strong, nonatomic, readwrite, nullable) CKCertificateBundle * appleBundle;
@property (strong, nonatomic, readwrite, nullable) CKCertificateBundle * googleBundle;
@property (strong, nonatomic, readwrite, nullable) CKCertificateBundle * microsoftBundle;
@property (strong, nonatomic, readwrite, nullable) CKCertificateBundle * mozillaBundle;

@end

@implementation CKRootCACertificateBundleManager

INSERT_OPENSSL_ERROR_METHOD

- (id) init {
    self = [super init];
    self.urlSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:nil];
    NSString * documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    self.bundleDirectory = [documentsDirectory stringByAppendingPathComponent:@"rootca"];
    self.bundleFiles = @[
        @"bundle_metadata.json",
        @"apple_ca_bundle.p7b",
        @"google_ca_bundle.p7b",
        @"microsoft_ca_bundle.p7b",
        @"mozilla_ca_bundle.p7b",
    ];
    self.signingKey = [NSData dataWithBytes:ROOTCA_SIGNING_PUBLICKEY1_BYTES length:ROOTCA_SIGNING_PUBLICKEY1_LEN];
    return self;
}

+ (CKRootCACertificateBundleManager *) sharedInstance {
    if (!_instance) {
        _instance = [CKRootCACertificateBundleManager new];
        [_instance loadBundles];
    }
    return _instance;
}

- (void) loadBundles {
    NSString * bundleDatePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"bundle_version" ofType:@"txt"];
    NSString * bundleTag = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:bundleDatePath] encoding:NSUTF8StringEncoding];
    bundleTag = [bundleTag stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    self.embeddedBundleTag = bundleTag;

    NSString * bundleMetadataPath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"bundle_metadata" ofType:@"json"];
    NSData * bundleData = [NSData dataWithContentsOfFile:bundleMetadataPath];
    self.embeddedBundleMetadata = [NSJSONSerialization JSONObjectWithData:bundleData options:kNilOptions error:nil];

    if ([self shouldUseDownloadedBundles]) {
        PDebug(@"[rootca] loading downloaded bundles");
        self.usingDownloadedBundles = [self loadDownloadedBundles];
    }

    if (!self.usingDownloadedBundles) {
        PDebug(@"[rootca] loading embedded bundles");
        [self loadEmbeddedBundles];
        self.usingDownloadedBundles = NO;
    }
}

- (BOOL) shouldUseDownloadedBundles {
    BOOL isDirectory = NO;
    if (![NSFileManager.defaultManager fileExistsAtPath:self.bundleDirectory isDirectory:&isDirectory]) {
        return NO; // Dir does not exist
    }
    if (!isDirectory) {
        PError(@"[rootca] File at path where bundle directory was expected");
        [NSFileManager.defaultManager removeItemAtPath:self.bundleDirectory error:nil];
        return NO; // Dir exists but is file
    }

    for (NSString * fileName in self.bundleFiles) {
        NSString * filePath = [self.bundleDirectory stringByAppendingPathComponent:fileName];
        NSString * signatureName = [NSString stringWithFormat:@"%@.sig", fileName];
        NSString * signaturePath = [self.bundleDirectory stringByAppendingPathComponent:signatureName];

        if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            return NO; // file does not exist
        }
        if (![NSFileManager.defaultManager fileExistsAtPath:signaturePath]) {
            PError(@"[rootca] Downloaded file does not have associated signature file");
            return NO; // signature does not exist
        }

        if (![self verifyFileSignature:filePath signature:signaturePath]) {
            PError(@"[rootca] Downloaded file has bad signature %@", filePath);
            return NO; // bad signature
        }
    }

    NSData * bundleData = [NSData dataWithContentsOfFile:[self.bundleDirectory stringByAppendingPathComponent:@"bundle_metadata.json"]];
    NSError * jsonError;
    NSDictionary<NSString *, id> * metadata = [NSJSONSerialization JSONObjectWithData:bundleData options:kNilOptions error:&jsonError];
    if (jsonError) {
        PError(@"[rootca] Downloaded metadata file is invalid: %@", jsonError.localizedDescription);
        return NO;
    }
    NSDateFormatter * formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-ddTHH:mm:ssZ"; // 2022-10-11T03:12:05Z

    for (NSString * key in @[@"apple", @"google", @"microsoft", @"mozilla"]) {
        NSDate * downloadDate = [formatter dateFromString:metadata[key][@"date"]];
        NSDate * embedDate = [formatter dateFromString:self.embeddedBundleMetadata[key][@"date"]];
        if (embedDate > downloadDate) {
            return NO; // embedded bundle is newer
        }

        NSString * fileName = [NSString stringWithFormat:@"%@_ca_bundle.p7b", key];
        NSString * filePath = [self.bundleDirectory stringByAppendingPathComponent:fileName];
        NSString * expectedChecksum = [metadata[key][@"bundles"][fileName][@"sha256"] uppercaseString];
        NSString * actualChecksum = [self getFileChecksum:filePath];
        if (actualChecksum == nil) {
            return NO;
        }
        if (![expectedChecksum isEqualToString:actualChecksum]) {
            PDebug(@"[rootca] Checksum result for %@:\r- Expected: %@\r- Actual: %@", fileName, expectedChecksum, actualChecksum);
            PError(@"[rootca] Downloaded bundle file failed checksum validation: %@", fileName);
            return NO;
        }
    }

    return YES;
}

- (BOOL) loadDownloadedBundles {
    NSString * bundleMetadataPath = [self.bundleDirectory stringByAppendingPathComponent:@"bundle_metadata.json"];
    NSData * bundleData = [NSData dataWithContentsOfFile:bundleMetadataPath];
    NSDictionary<NSString *, id> * metadata = [NSJSONSerialization JSONObjectWithData:bundleData options:kNilOptions error:nil];

    NSError * bundleError;

    NSString * appleBundlePath = [self.bundleDirectory stringByAppendingPathComponent:@"apple_ca_bundle.p7b"];
    CKCertificateBundle * appleBundle = [CKCertificateBundle bundleWithName:@"apple" bundlePath:appleBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:metadata[@"apple"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading downloaded apple bundle: %@", bundleError.localizedDescription);
        return NO;
    }

    NSString * googleBundlePath = [self.bundleDirectory stringByAppendingPathComponent:@"google_ca_bundle.p7b"];
    CKCertificateBundle * googleBundle = [CKCertificateBundle bundleWithName:@"google" bundlePath:googleBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:metadata[@"google"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading downloaded google bundle: %@", bundleError.localizedDescription);
        return NO;
    }

    NSString * microsoftBundlePath = [self.bundleDirectory stringByAppendingPathComponent:@"microsoft_ca_bundle.p7b"];
    CKCertificateBundle * microsoftBundle = [CKCertificateBundle bundleWithName:@"microsoft" bundlePath:microsoftBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:metadata[@"microsoft"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading downloaded microsoft bundle: %@", bundleError.localizedDescription);
        return NO;
    }

    NSString * mozillaBundlePath = [self.bundleDirectory stringByAppendingPathComponent:@"mozilla_ca_bundle.p7b"];
    CKCertificateBundle * mozillaBundle = [CKCertificateBundle bundleWithName:@"mozilla" bundlePath:mozillaBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:metadata[@"mozilla"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading downloaded mozilla bundle: %@", bundleError.localizedDescription);
        return NO;
    }

    self.appleBundle = appleBundle;
    self.mozillaBundle = mozillaBundle;
    self.microsoftBundle = microsoftBundle;
    self.googleBundle = googleBundle;
    PDebug(@"[rootca] Loaded downloaded bundles");
    return YES;
}

- (void) loadEmbeddedBundles {
    NSError * bundleError;

    NSString * appleBundlePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"apple_ca_bundle" ofType:@"p7b"];
    self.appleBundle = [CKCertificateBundle bundleWithName:@"apple" bundlePath:appleBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:self.embeddedBundleMetadata[@"apple"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading embedded apple bundle: %@", bundleError.localizedDescription);
        return;
    }

    NSString * googleBundlePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"google_ca_bundle" ofType:@"p7b"];
    self.googleBundle = [CKCertificateBundle bundleWithName:@"google" bundlePath:googleBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:self.embeddedBundleMetadata[@"google"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading embedded google bundle: %@", bundleError.localizedDescription);
        return;
    }

    NSString * microsoftBundlePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"microsoft_ca_bundle" ofType:@"p7b"];
    self.microsoftBundle = [CKCertificateBundle bundleWithName:@"microsoft" bundlePath:microsoftBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:self.embeddedBundleMetadata[@"microsoft"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading embedded microsoft bundle: %@", bundleError.localizedDescription);
        return;
    }

    NSString * mozillaBundlePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"mozilla_ca_bundle" ofType:@"p7b"];
    self.mozillaBundle = [CKCertificateBundle bundleWithName:@"mozilla" bundlePath:mozillaBundlePath metadata:[CKCertificateBundleMetadata metadataFrom:self.embeddedBundleMetadata[@"mozilla"]] error:&bundleError];
    if (bundleError != nil) {
        PError(@"[rootca] Error loading embedded mozilla bundle: %@", bundleError.localizedDescription);
        return;
    }
}

- (void) updateNow:(NSError **)errorPtr {
    NSDictionary<NSString *, id> * release;
    NSError * error;
    [self getLatestRootcaRelease:&release error:&error];
    if (error != nil) {
        *errorPtr = error;
        PError(@"[rootca] error getting latest release: %@", error.localizedDescription);
        return;
    }

    NSString * tagName = release[@"tag_name"];
    PDebug(@"[rootca] Latest tag: %@", tagName);

    if ([tagName isEqualToString:self.embeddedBundleTag] || (self.downloadedBundleTag != nil && [tagName isEqualToString:self.downloadedBundleTag])) {
        PDebug(@"[rootca] no updates needed");
        *errorPtr = MAKE_ERROR(200, @"success");
        return;
    }

    if ([NSFileManager.defaultManager fileExistsAtPath:self.bundleDirectory]) {
        [NSFileManager.defaultManager removeItemAtPath:self.bundleDirectory error:nil];
    }
    NSError * mkdirError;
    [NSFileManager.defaultManager createDirectoryAtPath:self.bundleDirectory withIntermediateDirectories:YES attributes:nil error:&mkdirError];
    if (mkdirError != nil) {
        *errorPtr = mkdirError;
        PError(@"[rootca] error making working directory: %@", self.bundleDirectory);
        return;
    }

    for (NSString * fileName in self.bundleFiles) {
        NSString * filePath = [self.bundleDirectory stringByAppendingPathComponent:fileName];
        NSString * fileURL = [NSString stringWithFormat:@"https://github.com/tls-inspector/rootca/releases/download/%@/%@", tagName, fileName];
        [self downloadFile:fileURL toFile:filePath error:&error];
        if (error != nil) {
            *errorPtr = error;
            PError(@"[rootca] error downloading asset %@: %@", fileURL, error.localizedDescription);
            goto CLEANUP;
        }
        NSString * signatureName = [NSString stringWithFormat:@"%@.sig", fileName];
        NSString * signaturePath = [self.bundleDirectory stringByAppendingPathComponent:signatureName];
        NSString * signatureURL = [NSString stringWithFormat:@"https://github.com/tls-inspector/rootca/releases/download/%@/%@", tagName, signatureName];
        [self downloadFile:signatureURL toFile:signaturePath error:&error];
        if (error != nil) {
            *errorPtr = error;
            PError(@"[rootca] error downloading asset %@: %@", signatureURL, error.localizedDescription);
            goto CLEANUP;
        }

        BOOL verifyResult = [self verifyFileSignature:filePath signature:signaturePath];
        if (!verifyResult) {
            PError(@"[rootca] verification failed %@", fileName);
            *errorPtr = MAKE_ERROR(500, @"File signature verification failed");
            goto CLEANUP;
        }
        PDebug(@"[rootca] verification OK %@", fileName);
    }

    // Confidence check
    if (![self shouldUseDownloadedBundles]) {
        PDebug(@"[rootca] download validation failed");
        *errorPtr = MAKE_ERROR(500, @"Valid validation failed");
        goto CLEANUP;
    }

    [self loadDownloadedBundles];
    self.usingDownloadedBundles = YES;
    PDebug(@"[rootca] update successful");
    return;
CLEANUP:
    [NSFileManager.defaultManager removeItemAtPath:self.bundleDirectory error:nil];
    return;
}

- (void) clearDownloadedBundles {
    [NSFileManager.defaultManager removeItemAtPath:self.bundleDirectory error:nil];
    [self loadBundles];
}

#pragma mark - Network Requests

- (void) getLatestRootcaRelease:(NSDictionary<NSString *, id> **)releasePtr error:(NSError **)errorPtr {
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/repos/tls-inspector/rootca/releases/latest"]];

    NSData * data;
    NSURLResponse * urlResponse;
    NSError * error;

    [self sendURLRequest:request withData:&data urlResponse:&urlResponse error:&error];
    if (error != nil) {
        *errorPtr = error;
        return;
    }
    if (((NSHTTPURLResponse *)urlResponse).statusCode != 200) {
        NSString * errDescription = [NSString stringWithFormat:@"HTTP %ld", (long)((NSHTTPURLResponse *)urlResponse).statusCode];
        *errorPtr = MAKE_ERROR(1, errDescription);
        return;
    }

    NSError * jsonError;
    NSDictionary<NSString *, id> * result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    *releasePtr = result;
}

- (void) downloadFile:(NSString *)fileURL toFile:(NSString *)filePath error:(NSError **)errorPtr {
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];

    NSData * data;
    NSURLResponse * urlResponse;
    NSError * error;

    [self sendURLRequest:request withData:&data urlResponse:&urlResponse error:&error];
    if (error != nil) {
        *errorPtr = error;
        return;
    }
    if (((NSHTTPURLResponse *)urlResponse).statusCode != 200) {
        NSString * errDescription = [NSString stringWithFormat:@"HTTP %ld", (long)((NSHTTPURLResponse *)urlResponse).statusCode];
        *errorPtr = MAKE_ERROR(1, errDescription);
        return;
    }

    NSError * writeError;
    if (![data writeToFile:filePath options:NSDataWritingAtomic error:&writeError]) {
        PError(@"[rootca] unable to write to file %@: %@", filePath, writeError.localizedDescription);
        NSString * description = [NSString stringWithFormat:@"Unable to write to file: %@", writeError.localizedDescription];
        *errorPtr = MAKE_ERROR(1, description);
        return;
    }
    PDebug(@"[rootca] downloaded %@ to file %@", fileURL, filePath);
}

#pragma mark - URL Session Delegate

- (void) URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    if (serverTrust == nil) {
        return;
    }

    SecTrustResultType trustResult;
    SecTrustEvaluate(serverTrust, &trustResult);

    if (trustResult != kSecTrustResultUnspecified && trustResult != kSecTrustResultProceed) {
        PError(@"[rootca] Trust failure connecting to host");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    long certificateCount = SecTrustGetCertificateCount(serverTrust);
    CKCertificate * rootCertificate = [CKCertificate fromSecCertificateRef:SecTrustGetCertificateAtIndex(serverTrust, certificateCount-1)];

    if (![self.mozillaBundle containsCertificate:rootCertificate]) {
        PError(@"[rootca] Unable to assert strong trust of connection to host");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
}

- (void) sendURLRequest:(NSURLRequest *)request withData:(NSData **)dataPtr urlResponse:(NSURLResponse **)urlResponsePtr error:(NSError **)errorPtr {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSData * __block data;
    NSURLResponse * __block urlResponse;
    NSError * __block error;

    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable rdata, NSURLResponse * _Nullable rresponse, NSError * _Nullable rerror) {
        data = rdata;
        urlResponse = rresponse;
        error = rerror;
        dispatch_semaphore_signal(semaphore);
    }] resume];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    *dataPtr = data;
    *urlResponsePtr = urlResponse;
    *errorPtr = error;
}

# pragma mark - Signature validation

- (BOOL) verifyFileSignature:(NSString *)filePath signature:(NSString *)signaturePath {
    int ret = -1;
    NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    NSData * signatureData = [NSData dataWithContentsOfFile:signaturePath];
    if (fileData == nil || signatureData == nil) {
        PError(@"[rootca] Error loading file or signature data");
        return NO;
    }

    EVP_MD_CTX *mctx = EVP_MD_CTX_new();
    EVP_PKEY_CTX *pctx = NULL;
    BIO * pubKeyBio = BIO_new_mem_buf(self.signingKey.bytes, (int)self.signingKey.length);
    EVP_PKEY *pubKey = PEM_read_bio_PUBKEY(pubKeyBio, NULL, NULL, NULL);
    if (pubKey == NULL) {
        PError(@"[rootca] Error loading rootca signing key");
        [self openSSLError];
        goto CLEANUP;
    }
    if (!EVP_DigestVerifyInit(mctx, &pctx, EVP_sha256(), NULL, pubKey)) {
        PError(@"[rootca] Error loading EVP digest");
        [self openSSLError];
        goto CLEANUP;
    }
    ret = EVP_DigestVerify(mctx, signatureData.bytes, signatureData.length, fileData.bytes, fileData.length);

CLEANUP:
    EVP_PKEY_free(pubKey);
    EVP_MD_CTX_free(mctx);
    BIO_free(pubKeyBio);
    return ret == 1;
}

- (NSString *) getFileChecksum:(NSString *)filePath {
    NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    if (fileData == nil) {
        PError(@"[rootca] Error loading file data");
        return nil;
    }

    unsigned char hashBytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(fileData.bytes, (unsigned int)fileData.length, hashBytes);
    NSMutableString * computedHash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [computedHash appendFormat:@"%02X", hashBytes[i]];
    }
    return computedHash;
}

@end
