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
#import "CKCertificateRevoked.h"
#import "CKCertificatePublicKey.h"

@class CKCertificateRevoked;
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
 *  Array of URLs representing distribution points for CRLs
 */
typedef NSArray<NSURL *> distributionPoints;

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
 *  Certificate revocation information
 */
@property (strong, nonatomic, nullable) CKCertificateRevoked * revoked;

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
 *  Test if current date is within the certificates issue date range
 *
 *  @return current date within range?
 */
- (BOOL) validIssueDate;

/**
 *  Retuns the issuer name
 */
@property (strong, nonatomic, nullable, readonly) NSString * issuer;

/**
 *  Is this a certificate authority
 */
@property (nonatomic, readonly) BOOL isCA;

/**
 *  Retruns a dictionary with the subject names, and name types (OU or CN)
 */
@property (strong, nonatomic, nullable, readonly) NSDictionary<NSString *, NSString *> * names;

/**
 *  Returns an array of subject names applicable to the cert
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSString *> * subjectAlternativeNames;

/**
 *  Returns the public key encoded using Privacy-Enhanced Electronic Mail (PEM) includes header and footer.
 */
@property (strong, nonatomic, nullable, readonly) NSData * publicKeyAsPEM;

/**
 *  Returns the authority that manages the extended validation for this certificate.
 */
@property (strong, nonatomic, nullable, readonly) NSString * extendedValidationAuthority;

/**
 *  Get an array of CRL distributionPoints (an array of URLs)
 */
@property (strong, nonatomic, nullable, readonly) distributionPoints * crlDistributionPoints;

/**
 *  Get an array of key usage identifiers
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSString *> * keyUsage;

/**
 *  Get an array of extended key usage identifiers
 */
@property (strong, nonatomic, nullable, readonly) NSArray<NSString *> * extendedKeyUsage;

/**
 *  Get the libssl X509 data structure for the certificate. Safe to force-cast to X509 * if not NULL.
 */
@property (nonatomic, nullable, readonly) void * X509Certificate;

/**
 *  Get the OpenSSL version used by CKCertificate
 *
 *  @return (NSString *) The OpenSSL version E.G. "1.1.0e"
 */
+ (NSString * _Nonnull) openSSLVersion;
@end
