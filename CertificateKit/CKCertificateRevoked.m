#import "CKCertificateRevoked.h"
#import "NSDate+ASN1_TIME.h"

#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/ossl_typ.h>
#include <openssl/x509v3.h>

@interface CKCertificateRevoked () {
    void (^finishedBlock)(NSError *);
    CKCertificate * certificate;
    CKCertificate * root;
    NSUInteger crlsRemaining;
    NSMutableArray<NSData *> * crlDataArray;
}

@property (strong, nonatomic, readwrite) NSDate * date;

@end

@implementation CKCertificateRevoked

- (void) isCertificateRevoked:(CKCertificate *)cert rootCA:(CKCertificate *)rootCA finished:(void (^)(NSError * error))finished {
    finishedBlock = finished;
    certificate = cert;
    root = rootCA;
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

        EVP_PKEY * pubKey = X509_get_pubkey(root.X509Certificate);
        X509_CRL * crl;
        const ASN1_INTEGER * serial = X509_get0_serialNumber(certificate.X509Certificate);

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
            int reason = X509_CRL_get0_by_serial(crl, &revoked, (ASN1_INTEGER *)serial);
            if (reason >= 0) {
                self.isRevoked = YES;
                self.reason = reason;
                
                const ASN1_TIME * revokedTime = X509_REVOKED_get0_revocationDate(revoked);
                self.date = [NSDate fromASN1_TIME:revokedTime];
            }
            X509_CRL_free(crl);
        }
        
        NSLog(@"Finished checking CRLs");
        finishedBlock(nil);
    }
}

@end
