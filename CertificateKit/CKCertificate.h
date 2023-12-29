//
//  CKCertificate.h
//
//  LGPLv3
//
//  Copyright (c) 2016 Ian Spence
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

#import <Foundation/Foundation.h>
#import "CKCertificatePublicKey.h"
#import "CKNameObject.h"
#import "CKAlternateNameObject.h"
#import "CKRevoked.h"
#import "CKSignedCertificateTimestamp.h"
#import "CKCertificateExtension.h"

@class CKCertificatePublicKey;

/**
 *  A CKCertificate is the front-end to a libssl X.509 certificate.
 */
@interface CKCertificate : NSObject

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
@property (strong, nonatomic, nonnull, readonly) NSString * summary;

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
 *  Returns the certificate version
 */
@property (strong, nonatomic, nullable, readonly) NSNumber * version;

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
 *  The number of days this certificate is valid
 */
@property (nonatomic) NSUInteger validDays;

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
 * Is this certificate self signed
 */
@property (nonatomic) BOOL isSelfSigned;

/**
 *  Information about the certificates revocation status.
 */
@property (strong, nonatomic, nonnull) CKRevoked * revoked;

/**
 *  Is this a certificate authority
 */
@property (nonatomic, readonly) BOOL isCA;

/**
 *  Returns an array of subject names applicable to the cert
 */
@property (strong, nonatomic, nullable, readonly) NSArray<CKAlternateNameObject *> * alternateNames;

/**
 *  Returns the public key encoded using Privacy-Enhanced Electronic Mail (PEM) includes header and footer.
 */
@property (strong, nonatomic, nullable, readonly) NSData * publicKeyAsPEM;

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
 *  Get a dictionary of all key identifiers
 */
@property (strong, nonatomic, nullable, readonly) NSDictionary<NSString *, NSString *> * keyIdentifiers;

/**
 *  Dictionary mapping the vendor name (e.g. mozilla) to if the certificate is present in their root ca bundle. Only populated on self-signed certificates.
 */
@property (strong, nonatomic, nullable) NSDictionary<NSString *, NSNumber *> * vendorTrustStatus;

/**
 *  List of signed certificate timestamps embedded in the certificate
 */
@property (strong, nonatomic, nullable) NSArray<CKSignedCertificateTimestamp *> * signedTimestamps;

/**
 *  List of extra X.509 certificate extensions not covered by other properties of this certificate.
 *  Excluded extensions include: `isCA`, Alternate Names, CRL & OCSP URLs, Key Usage & Extended Key Usage, TLS Features, Key Identifieres
 */
@property (strong, nonatomic, nullable, readonly) NSArray<CKCertificateExtension *> * extraExtensions;

/**
 *  Return a detailed description of the certificate
 */
- (NSString * _Nonnull) description;

@end
