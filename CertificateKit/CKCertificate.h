//
//  CKCertificate.h
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
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
#import "CKCertificatePublicKey.h"
#import "CKNameObject.h"
#import "CKAlternateNameObject.h"
#import "CKRevoked.h"

@class CKCertificatePublicKey;

/**
 *  A CKCertificate is the front-end to a libssl X.509 certificate.
 */
@interface CKCertificate : NSObject

/**
 *  Create a CKCertificate object from a pre-existing X509 object.
 *
 *  @param cert A libssl compliant X509 cert.
 *
 *  @return A CKCertificate instance
 */
+ (CKCertificate * _Nullable) fromX509:(void * _Nonnull)cert;

/**
 *  Create a CKCertificate object from a pre-existing X509 object.
 *
 *  @param cert A SecCertificateRef certificate reference
 *
 *  @return A CKCertificate instance
 */
+ (CKCertificate * _Nullable) fromSecCertificateRef:(SecCertificateRef _Nonnull)cert;

/**
 *  Finger (thumb) print types that CKCertificate can export
 */
typedef NS_ENUM(NSInteger, CKCertificateFingerprintType) {
    /**
     * SHA 512 fingerprint type
     */
    CKCertificateFingerprintTypeSHA512,
    /**
     * SHA 512 fingerprint type
     */
    CKCertificateFingerprintTypeSHA256,
    /**
     * SHA 512 fingerprint type
     */
    CKCertificateFingerprintTypeMD5,
    /**
     * SHA 512 fingerprint type
     */
    CKCertificateFingerprintTypeSHA1
};

/**
 *  The common name of the certificate
 */
@property (strong, nonatomic, nullable, readonly) NSString * summary;

/**
 *  If the certificate is an EV certificate. See `extendedValidationAuthority` for more.
 */
@property (nonatomic, readonly) BOOL extendedValidation;

/**
 *  Returns the SHA512 fingerprint for the certificate
 */
@property (strong, nonatomic, nullable, readonly) NSString * SHA512Fingerprint;

/**
 *  Returns the SHA256 fingerprint for the certificate
 */
@property (strong, nonatomic, nullable, readonly) NSString * SHA256Fingerprint;

/**
 *  Returns the MD5 fingerprint for the certificate
 *
 *  Warning! The security of the MD5 algorithm has been seriously compromised - avoid use!
 */
@property (strong, nonatomic, nullable, readonly) NSString * MD5Fingerprint;

/**
 *  Returns the SHA1 fingerprint for the certificate
 *
 *  Warning! SH1 is no longer considered cryptographically secure - avoid use!
 */
@property (strong, nonatomic, nullable, readonly) NSString * SHA1Fingerprint;

/**
 *  Verify the fingerprint of the certificate. Useful for certificate pinning.
 *
 *  @param fingerprint The fingerprint
 *  @param type        The type of hashing method used to generate the fingerprint
 *
 *  @return YES if verified
 */
- (BOOL) verifyFingerprint:(NSString * _Nonnull)fingerprint type:(CKCertificateFingerprintType)type;

/**
 *  Returns the serial number for the certificate
 */
@property (strong, nonatomic, nullable, readonly) NSString * serialNumber;

/**
 *  Returns the human readable signature algorithm
 */
@property (strong, nonatomic, nullable, readonly) NSString * signatureAlgorithm;

/**
 *  Returns information about the certificates public key
 */
@property (strong, nonatomic, nullable, readonly) CKCertificatePublicKey * publicKey;

/**
 *  Returns the expiry date for the certificate. Time data may be unavailable and should not be relied upon.
 */
@property (strong, nonatomic, nullable, readonly) NSDate * notAfter;

/**
 *  Returns the start date for the certificate. Time data may be unavailable and should not be relied upon.
 */
@property (strong, nonatomic, nullable, readonly) NSDate * notBefore;

/**
 *  Returns if the certificates is between the start and expiry date.
 */
@property (nonatomic, readonly) BOOL isDateValid;

/**
 *  Returns if the certificates notAfter date is in the past
 */
@property (nonatomic, readonly) BOOL isExpired;

/**
 *  Returns if the certificates notBefore date is in the future
 */
@property (nonatomic, readonly) BOOL isNotYetValid;

/**
 *  Returns the certificates subject names.
 */
@property (strong, nonatomic, nonnull, readonly) CKNameObject * subject;

/**
 *  Returns the certificates issuers subject names.
 */
@property (strong, nonatomic, nonnull, readonly) CKNameObject * issuer;

/**
 *  Information about the certificates revocation status.
 */
@property (strong, nonatomic, nonnull) CKRevoked * revoked;

/**
 *  Is this a certificate authority
 */
@property (nonatomic, readonly) BOOL isCA;

/**
 *  Is this certificate a root certificate, installed on your device.
 */
@property (nonatomic) BOOL isRootCA;

/**
 *  Returns an array of subject names applicable to the cert
 */
@property (strong, nonatomic, nullable, readonly) NSArray<CKAlternateNameObject *> * alternateNames;

/**
 *  Returns the public key encoded using Privacy-Enhanced Electronic Mail (PEM) includes header and footer.
 */
@property (strong, nonatomic, nullable, readonly) NSData * publicKeyAsPEM;

/**
 *  Returns the authority that manages the extended validation for this certificate.
 */
@property (strong, nonatomic, nullable, readonly) NSString * extendedValidationAuthority;

/**
 *  Returns the URL for which OCSP queries can be performed for this certificate.
 */
@property (strong, nonatomic, nullable, readonly) NSURL * ocspURL;

/**
 *  Returns an array of URLs that contain certificate revocation lists.
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSURL *> * crlDistributionPoints;

/**
 *  Get an array of key usage identifiers
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSString *> * keyUsage;

/**
 *  Get an array of extended key usage identifiers
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSString *> * extendedKeyUsage;

/**
 *  Get an array of TLS features for this certificate
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSString *> * tlsFeatures;

/**
 *  Get the libssl X509 data structure for the certificate. Safe to force-cast to X509 * if not NULL.
 */
@property (nonatomic, nullable, readonly) void * X509Certificate;

@end
