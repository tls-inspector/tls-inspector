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

/**
 Revocation information about a CKCertificate
 */
@interface CKCertificateRevoked : NSObject

/**
 The possible reasons a certificate can be revoked as defined in RFC 5280.
 */
typedef NS_ENUM(NSInteger, CKCertificateRevokedReason) {
    /**
     No reason is specified for the revocation.
     */
    CKCertificateRevokedReasonUnspecified          = 0,
    /**
     It is known or is suspected that the subject's private key or other aspects of the subject that are validated in the certificate are compromised.
     */
    CKCertificateRevokedReasonKeyCompromise        = 1,
    /**
     It is known or is suspected that the certification authority's (CA's) private key or other aspects of the CA that are validated in the certificate are compromised.
     */
    CKCertificateRevokedReasonCACompromise         = 2,
    /**
     The subject's name or other information in the certificate has been modified, but there is no cause to suspect that the private key has been compromised.
     */
    CKCertificateRevokedReasonAffiliationChanged   = 3,
    /**
     The certificate has been superseded, but there is no cause to suspect that the private key has been compromised.
     */
    CKCertificateRevokedReasonSuperseded           = 4,
    /**
     The certificate is no longer needed for the purpose for which it was issued, but there is no cause to suspect that the private key has been compromised.
     */
    CKCertificateRevokedReasonCessationOfOperation = 5,
    /**
     The certificate has been put on hold.
     */
    CKCertificateRevokedReasonCertificateHold      = 6,
    /**
     The certificate shall be removed from the CRL.
     */
    CKCertificateRevokedReasonRemoveFromCRL        = 8,
    /**
     Indicates that a certificate (public-key or attribute certificate) was revoked because a privilege contained within that certificate has been withdrawn.
     */
    CKCertificateRevokedReasonPrivilegeWithdrawn   = 9,
    /**
     Indicates that it is known or suspected that aspects of the AA validated in the attribute certificate, have been compromised.
     */
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
