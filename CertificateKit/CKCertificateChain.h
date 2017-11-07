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
     The system trusts this certificate
     */
    CKCertificateChainTrustStatusTrusted,
    /**
     The system does not trust this certificate
     */
    CKCertificateChainTrustStatusUntrusted,
    /**
     The server certificate of this chain is revoked
     */
    CKCertificateChainTrustStatusRevoked,
    /**
     The server certificate is not issued by any CA and is not manually installed
     */
    CKCertificateChainTrustStatusSelfSigned,
};

/**
 The domain for the certificate chain
 */
@property (strong, nonatomic, nonnull) NSString * domain;

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
 Get the negotiated ciphersuite used to retrieve the chain
 */
@property (nonatomic) SSLCipherSuite cipher;

/**
 Get the negotiated protocol used to retrieve the chain
 */
@property (nonatomic) SSLProtocol protocol;

/**
 *  Query the specified URL for its certificate chain.
 *
 *  @param URL      The URL to query. Must use the https scheme.
 *                  The port is optional and will default to 443.
 *  @param finished Called when finished with either an error or certificate chain.
 */
;

@end
