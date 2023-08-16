//
//  CKCertificateChain.h
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
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
#import "CKCertificate.h"
#import "CKIPAddress.h"

/**
 A chain of CKCertificate objects and metadata about the chain
 */
@interface CKCertificateChain : NSObject

/**
 The trust status of the certificate.
 */
typedef NS_ENUM(NSInteger, CKCertificateChainTrustStatus) {
    /**
     The system trusts this certificate.
     */
    CKCertificateChainTrustStatusTrusted,
    /**
     The system trusts this certificate chain because one or more of the certificates
     are locally installed and marked as trusted.
     */
    CKCertificateChainTrustStatusLocallyTrusted,
    /**
     The system does not trust this certificate.
     */
    CKCertificateChainTrustStatusUntrusted,
    /**
     The system does not trust this certificate because one or more certificates in the chain
     are expired or not yet valid.
     */
    CKCertificateChainTrustStatusInvalidDate,
    /**
     The system does not trust this certificate because the server certificate is for a different host.
     */
    CKCertificateChainTrustStatusWrongHost,
    /**
     The system does not trust this certificate because the server certificate is signed using SHA-1.
     */
    CKCertificateChainTrustStatusSHA1Leaf,
    /**
     The system does not trust this certificate because the intermediate certificate is signed using SHA-1.
     */
    CKCertificateChainTrustStatusSHA1Intermediate,
    /**
     The system does not trust this certificate because it is a self-signed certificate.
     */
    CKCertificateChainTrustStatusSelfSigned,
    /**
     The system does not trust this certificate because is has been revoked.
     */
    CKCertificateChainTrustStatusRevokedLeaf,
    /**
     The system does not trust this certificate because the intermediate CA has been revoked.
     */
    CKCertificateChainTrustStatusRevokedIntermediate,
    /**
     The leaf or intermediate certificate is using an RSA bey with fewer than 2048 bits.
     */
    CKCertificateChainTrustStatusWeakRSAKey,
    /**
     The leaf certificate has an issue date longer than 825 days
     */
    CKCertificateChainTrustStatusIssueDateTooLong,
    /**
     The leaf certificate is missing require key usage permissions
     */
    CKCertificateChainTrustStatusLeafMissingRequiredKeyUsage,
    /**
     The root or intermediate authority is known to violate internationally accepted rules
     */
    CKCertificateChainTrustStatusBadAuthority,
};

/**
 The domain for the certificate chain
 */
@property (strong, nonatomic, nonnull) NSString * domain;

/**
 The remote address for the server
 */
@property (strong, nonatomic, nonnull) CKIPAddress * remoteAddress;

/**
 The array of certificates belonging to the chain in the order of least to most specific.
 For example, 0 = root, 1 = intermediate, 2 = leaf/server
 */
@property (strong, nonatomic, nonnull) NSArray<CKCertificate *> * certificates;

/**
 If the system trusts the certificate chain
 */
@property (nonatomic) CKCertificateChainTrustStatus trustStatus;

/**
 Get the negotiated ciphersuite used to retrieve the chain.
 */
@property (strong, nonatomic, nonnull) NSString * cipherSuite;

/**
 Get the negotiated protocol used to retrieve the chain.
 */
@property (strong, nonatomic, nonnull) NSString * protocol;

/**
 The NSS keylog data. Only available when using OpenSSL.
 */
@property (strong, nonatomic, nullable) NSString * keyLog;

/**
 *  List of signed certificate timestamps included in the handshake
 */
@property (strong, nonatomic, nullable) NSArray<CKSignedCertificateTimestamp *> * signedTimestamps;

/**
 Check if one or more certificates in the chain are known bad certificates
 */
- (void) checkAuthorityTrust;

/**
 Attempt to determine why the trust failed
 */
- (void) determineTrustFailureReason;

-(NSString * _Nonnull) description;

@end
