//
//  CKCertificateRevoked.h
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

#import <Foundation/Foundation.h>
#import "CKCertificate.h"

@class CKCertificate;

@interface CKCertificateRevoked : NSObject

typedef NS_ENUM(NSInteger, CKCertificateRevokedReason) {
    CKCertificateRevokedReasonUnspecified          = 0,
    CKCertificateRevokedReasonKeyCompromise        = 1,
    CKCertificateRevokedReasonCACompromise         = 2,
    CKCertificateRevokedReasonAffiliationChanged   = 3,
    CKCertificateRevokedReasonSuperseded           = 4,
    CKCertificateRevokedReasonCessationOfOperation = 5,
    CKCertificateRevokedReasonCertificateHold      = 6,
    CKCertificateRevokedReasonRemoveFromCRL        = 8,
    CKCertificateRevokedReasonPrivilegeWithdrawn   = 9,
    CKCertificateRevokedReasonAACompromise         = 10
};

/**
 Was the certificate serial number present on a CRL
 */
@property (nonatomic) BOOL isRevoked;

/**
 For what reason was the certificate revoked
 */
@property (nonatomic) CKCertificateRevokedReason reason;

/**
 The date that the certificate was revoked.
 */
@property (strong, nonatomic, readonly, nullable) NSDate * date;

/**
 A string representation of the reason for revocation.
 */
@property (strong, nonatomic, readonly, nullable) NSString * reasonString;

/**
 Determine the status of the certificate, verified against the intermediateCA.
 Will populate the instance of CKCertificateRevoked with the status when finished is called.

 @param cert The certificate to check
 @param intermediateCA The intermediate CA that issued the queried certificate
 @param finished Called when finished with an error if one occured.
 */
- (void) isCertificateRevoked:(CKCertificate * _Nonnull)cert
               intermediateCA:(CKCertificate * _Nonnull)intermediateCA
                     finished:(void (^ _Nonnull)(NSError * _Nullable error))finished;

@end
