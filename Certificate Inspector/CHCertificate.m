//
//  CHCertificate.m
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
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

#import "CHCertificate.h"

@implementation CHCertificate {
    void (^finishedCallback)(NSError * error,
                             NSArray<CHCertificate *>* certificates,
                             BOOL trustedChain);
    NSMutableArray<CHCertificate *>* certificates;
}

/**
 *  Retrieve the certificate chain for the specified URL
 *
 *  @param URL      The URL to retrieve
 *  @param finished Called when the network request has completed with either an error or an array
 *                  of certificates
 */
- (void) fromURL:(NSString *)URL finished:(void (^)(NSError * error,
                                                    NSArray<CHCertificate *>* certificates,
                                                    BOOL trustedChain))finished {
    finishedCallback = finished;
    certificates = [NSMutableArray new];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            finishedCallback(error, certificates, NO);
        }
    }] resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef trust = challenge.protectionSpace.serverTrust;
        SecTrustEvaluate(trust, NULL);
        long count = SecTrustGetCertificateCount(trust);
        for (int i = 0; i < count; i++) {
            CHCertificate * certificate = [CHCertificate withCertificateRef:SecTrustGetCertificateAtIndex(trust, i)];
            certificate.host = challenge.protectionSpace.host;
            [certificates addObject:certificate];
        }
        finishedCallback(nil, certificates, [CHCertificate trustedChain:trust]);
    }

    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

/**
 *  Creates a new CHCertificate object with the certificate reference
 *
 *  @param cert A SecCertificateRef reference to the cert object
 *
 *  @return an instatiated CHCertificate object
 */
+ (CHCertificate *) withCertificateRef:(SecCertificateRef)cert {
    CHCertificate * certificate = [CHCertificate new];
    certificate.cert = cert;
    NSData *certificateData = (NSData *)CFBridgingRelease(SecCertificateCopyData(cert));
    const unsigned char *certificateDataBytes = (const unsigned char *)[certificateData bytes];
    X509 *certificateX509 = d2i_X509(NULL, &certificateDataBytes, [certificateData length]);
    certificate.X509Certificate = certificateX509;
    certificate.summary = (__bridge NSString *)SecCertificateCopySubjectSummary(cert);

    return certificate;
}

+ (BOOL) trustedChain:(SecTrustRef)trust {
    SecTrustResultType resultType;
    SecTrustEvaluate(trust, &resultType);
    return resultType == kSecTrustResultUnspecified;
}

/**
 *  Returns the SHA256 fingerprint for the certificate
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) SHA256Fingerprint {
    return [self fingerprintWithType:kFingerprintTypeSHA256];
}

/**
 *  Returns the MD5 fingerprint for the certificate
 *
 *  Warning! The security of the MD5 algorithm has been seriously compromised - avoid use!
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) MD5Fingerprint {
    return [self fingerprintWithType:kFingerprintTypeMD5];
}

/**
 *  Returns the SHA1 fingerprint for the certificate
 *
 *  Warning! SH1 is no longer considered cryptographically secure - avoide use!
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) SHA1Fingerprint {
    return [self fingerprintWithType:kFingerprintTypeSHA1];
}

/**
 *  Verify the fingerprint of the certificate. Useful for certificate pinning.
 *
 *  @param fingerprint The fingerprint
 *  @param type        The type of hashing algrotim used to generate the fingerprint
 *
 *  @return YES if verified
 */
- (BOOL) verifyFingerprint:(NSString *)fingerprint type:(kFingerprintType)type {
    NSString * currentFingerprint;
    NSString * expectedFingerprint = fingerprint;
    switch (type) {
        case kFingerprintTypeSHA256:
            currentFingerprint = [self SHA256Fingerprint];
        case kFingerprintTypeSHA1:
            currentFingerprint = [self SHA1Fingerprint];
        case kFingerprintTypeMD5:
            currentFingerprint = [self MD5Fingerprint];
        default:
            currentFingerprint = @"";
    }
    NSString * (^formatFingerprint)(NSString *) = ^NSString *(NSString * fingerprint) {
        return [[fingerprint lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    };
    currentFingerprint = formatFingerprint(currentFingerprint);
    expectedFingerprint = formatFingerprint(expectedFingerprint);

    return [currentFingerprint isEqualToString:expectedFingerprint];
}

/**
 *  Returns the serial number for the certificate
 *
 *  @return A NSString value of the serial number
 */
- (NSString *) serialNumber {
    NSMutableString * s = [NSMutableString new];
    int length = (int)self.X509Certificate->cert_info->serialNumber->length;
    for (int i = 0; i < length; i++) {
        unsigned char data = (unsigned char)self.X509Certificate->cert_info->serialNumber->data[i];
        [s appendString:[NSString stringWithFormat:@"%02x", data]];
    }
    return s;
}

/**
 *  Returns the human readable signature algorithm
 *
 *  @return A NSString value of the algorithm
 */
- (NSString *) algorithm {
    X509_ALGOR * sig_type = self.X509Certificate->sig_alg;
    char buffer[128];
    OBJ_obj2txt(buffer, sizeof(buffer), sig_type->algorithm, 0);
    return [NSString stringWithUTF8String:buffer];
}

- (NSString *)fingerprintWithType:(kFingerprintType)type {
    if (!certificateData) {
        certificateData = CFBridgingRelease(SecCertificateCopyData(self.cert));
    }

    const NSUInteger length = [self lengthWithType:type];
    unsigned char buffer[length];

    switch (type) {
        case kFingerprintTypeSHA256: {
            CC_SHA256(certificateData.bytes, (CC_LONG)certificateData.length, buffer);
            break;
        }
        case kFingerprintTypeSHA1: {
            CC_SHA1(certificateData.bytes, (CC_LONG)certificateData.length, buffer);
            break;
        }
        case kFingerprintTypeMD5: {
            CC_MD5(certificateData.bytes, (CC_LONG)certificateData.length, buffer);
            break;
        }
    }

    NSMutableString *fingerprint = [NSMutableString stringWithCapacity:length * 3];

    for (int i = 0; i < length; i++) {
        [fingerprint appendFormat:@"%02x ",buffer[i]];
    }

    return [[fingerprint stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
}

- (NSUInteger)lengthWithType:(kFingerprintType)type
{
    switch (type) {
        case kFingerprintTypeSHA256: {
            return CC_SHA256_DIGEST_LENGTH;
        }
        case kFingerprintTypeSHA1: {
            return CC_SHA1_DIGEST_LENGTH;
        }
        case kFingerprintTypeMD5: {
            return CC_MD5_DIGEST_LENGTH;
        }
    }
}

/**
 *  Retuns the issuer name
 *
 *  @return A NSString value of the issuer identity
 */
- (NSString *) issuer {
    X509_NAME *issuerX509Name = X509_get_issuer_name(self.X509Certificate);

    if (issuerX509Name != NULL) {
        int nid = OBJ_txt2nid("O"); // organization
        int index = X509_NAME_get_index_by_NID(issuerX509Name, nid, -1);

        X509_NAME_ENTRY *issuerNameEntry = X509_NAME_get_entry(issuerX509Name, index);

        if (issuerNameEntry) {
            ASN1_STRING *issuerNameASN1 = X509_NAME_ENTRY_get_data(issuerNameEntry);

            if (issuerNameASN1 != NULL) {
                unsigned char *issuerName = ASN1_STRING_data(issuerNameASN1);
                return [NSString stringWithUTF8String:(char *)issuerName];
            }
        }
    }
    return @"";
}

/**
 *  Returns the expiry date for the certificate
 *
 *  @return A NSDate object for the "not after" field - Time is not critical for this date object.
 */
- (NSDate *) notAfter {
    return [self dateFromASNTIME:X509_get_notAfter(self.X509Certificate)];
}

/**
 *  Returns the start date for the certificate
 *
 *  @return A NSDate object for the "not before" field - Time is not critical for this date object.
 */
- (NSDate *) notBefore {
    return [self dateFromASNTIME:X509_get_notBefore(self.X509Certificate)];
}

- (NSDate *) dateFromASNTIME:(ASN1_TIME *)time {
    // Source: http://stackoverflow.com/a/8903088/1112669
    ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(time, NULL);
    if (certificateExpiryASN1Generalized != NULL) {
        unsigned char *certificateExpiryData = ASN1_STRING_data(certificateExpiryASN1Generalized);

        // ASN1 generalized times look like this: "20131114230046Z"
        //                                format:  YYYYMMDDHHMMSS
        //                               indices:  01234567890123
        //                                                   1111
        // There are other formats (e.g. specifying partial seconds or
        // time zones) but this is good enough for our purposes since
        // we only use the date and not the time.
        //
        // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)

        NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
        NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];

        expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
        expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
        expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
        expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
        expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
        expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        return [calendar dateFromComponents:expiryDateComponents];
    }
    return nil;
}

/**
 *  Test if current date is within the certificates issue date range
 *
 *  @return current date within range?
 */
- (BOOL) validIssueDate {
    BOOL valid = YES;
    if ([self.notBefore timeIntervalSinceNow] > 0) {
        valid = NO;
    }
    if ([self.notAfter timeIntervalSinceNow] < 0) {
        valid = NO;
    }
    return valid;
}

/**
 *  Retruns an array of dictionaries with the subjet names, and name types (OU or CN)
 *
 *  @return An array of dictionaries: [ { "type": "OU", "name": "*.foo" } ]
 */
- (NSArray<NSDictionary *> *) names {
    NSString * namesString = [NSString stringWithUTF8String:self.X509Certificate->name];
    NSMutableArray * names = [NSMutableArray new];
    NSArray * nameTypes;
    for (NSString * nameComponent in [namesString componentsSeparatedByString:@"/"]) {
        if (![nameComponent isEqualToString:@""]) {
            nameTypes = [nameComponent componentsSeparatedByString:@"="];
            [names addObject:@{@"type": nameTypes[0], @"name": nameTypes[1]}];
        }
    }
    return [NSArray arrayWithArray:names];
}

@end
