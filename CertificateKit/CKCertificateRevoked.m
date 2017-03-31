//
//  CKCertificateRevoked.M
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

#import "CKCertificateRevoked.h"
#import "NSDate+ASN1_TIME.h"

#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/ossl_typ.h>
#include <openssl/x509v3.h>

@interface CKCertificateRevoked () {
    void (^finishedBlock)(NSError *);
    CKCertificate * certificate;
    CKCertificate * intermediate;
    NSUInteger crlsRemaining;
    NSMutableArray<NSData *> * crlDataArray;
}

@property (strong, nonatomic, readwrite) NSDate * date;

@end

@implementation CKCertificateRevoked

- (void) isCertificateRevoked:(CKCertificate *)cert intermediateCA:(CKCertificate *)intermediateCA finished:(void (^)(NSError * error))finished {
    finishedBlock = finished;
    certificate = cert;
    intermediate = intermediateCA;
    crlDataArray = [NSMutableArray new];
    [[CKCRLManager sharedInstance] loadCRLCache];

    distributionPoints * crls = [cert crlDistributionPoints];
    crlsRemaining = crls.count;

    for (NSURL * url in crls) {
        [[CKCRLManager sharedInstance] getCRL:url finished:^(NSData *data, NSError *error) {
            if (error) {
                finished(error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    crlsRemaining --;
                    [crlDataArray addObject:data];
                    [self crlDownloaded];
                });
            }
        }];
    }
}

- (void) crlDownloaded {
    if (crlsRemaining == 0) {
        [[CKCRLManager sharedInstance] unloadCRLCache];

        EVP_PKEY * pubKey = X509_get_pubkey(intermediate.X509Certificate);
        X509_CRL * crl;

        for (NSData * crlData in crlDataArray) {
            const unsigned char * bytes = (const unsigned char *)[crlData bytes];
            crl = d2i_X509_CRL(NULL, &bytes, [crlData length]);

            int rv;
            if ((rv = X509_CRL_verify(crl, pubKey)) != 1) {
                // CRL Verification failure
                NSError * crlError = [NSError errorWithDomain:@"CKCRLManager" code:rv userInfo:@{NSLocalizedDescriptionKey: @"CRL verification failed"}];
                NSLog(@"CRL verification failed!");
                finishedBlock(crlError);
                return;
            }

            X509_REVOKED * revoked;
            rv = X509_CRL_get0_by_cert(crl, &revoked, certificate.X509Certificate);
            if (rv > 0) {
                // Certificate is revoked
                self.isRevoked = YES;
                const ASN1_TIME * revokedTime = X509_REVOKED_get0_revocationDate(revoked);
                self.date = [NSDate fromASN1_TIME:revokedTime];
                finishedBlock(nil);
            } else if (rv == 0) {
                // Certificate not revoked
                self.isRevoked = NO;
                finishedBlock(nil);
            } else {
                // CRL parsing failure
                NSError * crlError = [NSError errorWithDomain:@"CKCRLManager" code:rv userInfo:@{NSLocalizedDescriptionKey: @"CRL parsing failed"}];
                NSLog(@"CRL parsing failed!");
                finishedBlock(crlError);
            }
            X509_CRL_free(crl);
        }

        NSLog(@"Finished checking CRLs");
        finishedBlock(nil);
    }
}

- (NSString *) reasonString {
    switch (self.reason) {
        case CKCertificateRevokedReasonUnspecified:
            return @"Unspecified";
        case CKCertificateRevokedReasonKeyCompromise:
            return @"Key compromise";
        case CKCertificateRevokedReasonCACompromise:
            return @"CA compromise";
        case CKCertificateRevokedReasonAffiliationChanged:
            return @"Affiliation changed";
        case CKCertificateRevokedReasonSuperseded:
            return @"Superseded";
        case CKCertificateRevokedReasonCessationOfOperation:
            return @"Cessation of operation";
        case CKCertificateRevokedReasonCertificateHold:
            return @"Certificate hold";
        case CKCertificateRevokedReasonRemoveFromCRL:
            return @"Remove from CRL";
        case CKCertificateRevokedReasonPrivilegeWithdrawn:
            return @"Privilege withdrawn";
        case CKCertificateRevokedReasonAACompromise:
            return @"AA compromise";
    }
    return nil;
}

@end
