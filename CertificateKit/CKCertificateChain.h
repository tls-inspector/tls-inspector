//
//  CKCertificateChain.h
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
#import "CKServerInfo.h"

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
};

/**
 The domain for the certificate chain
 */
@property (strong, nonatomic, nonnull) NSString * domain;

/**
 The remote address for the server
 */
@property (strong, nonatomic, nonnull) NSString * remoteAddress;

/**
 The array of certificates belonging to the chain
 */
@property (strong, nonatomic, nonnull) NSArray<CKCertificate *> * certificates;

/**
 The root of the certificate chain. Will be nil for chains with only one certificate (I.E. self signed roots)
 */
@property (strong, nonatomic, nullable) CKCertificate * rootCA;

/**
 The intermediate CA of the certificate chain. Will be nil for chains with only one certificate (I.E. self signed roots)
 */
@property (strong, nonatomic, nullable) CKCertificate * intermediateCA;

/**
 The server certificate in the chain.
 */
@property (strong, nonatomic, nullable) CKCertificate * server;

/**
 If the system trusts the certificate chain
 */
@property (nonatomic) CKCertificateChainTrustStatus trusted;

/**
 Get the negotiated ciphersuite used to retrieve the chain.
 */
@property (strong, nonatomic, nonnull) NSString * cipherSuite;

/**
 Get the negotiated protocol used to retrieve the chain. Use protocolString to get a readable string.
 */
@property (nonatomic) int protocol;

@end
