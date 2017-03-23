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

@interface CKCertificateChain : NSObject

typedef NS_ENUM(NSInteger, CKCertificateChainTrustStatus) {
    /**
     The system trusts this certificate
     */
    CKCertificateChainTrustStatusTrusted,
    /**
     The system does not trust this certificate
     */
    CKCertificateChainTrustStatusUntrusted,
};

typedef NS_ENUM(NSUInteger, CKCertificateChainCipher) {
    CKCertificateChainCipher_SSL_NULL_WITH_NULL_NULL                 = 0x0000,
    CKCertificateChainCipher_SSL_RSA_WITH_NULL_MD5                   = 0x0001,
    CKCertificateChainCipher_SSL_RSA_WITH_NULL_SHA                   = 0x0002,
    CKCertificateChainCipher_SSL_RSA_EXPORT_WITH_RC4_40_MD5          = 0x0003,
    CKCertificateChainCipher_SSL_RSA_WITH_RC4_128_MD5                = 0x0004,
    CKCertificateChainCipher_SSL_RSA_WITH_RC4_128_SHA                = 0x0005,
    CKCertificateChainCipher_SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5      = 0x0006,
    CKCertificateChainCipher_SSL_RSA_WITH_IDEA_CBC_SHA               = 0x0007,
    CKCertificateChainCipher_SSL_RSA_EXPORT_WITH_DES40_CBC_SHA       = 0x0008,
    CKCertificateChainCipher_SSL_RSA_WITH_DES_CBC_SHA                = 0x0009,
    CKCertificateChainCipher_SSL_RSA_WITH_3DES_EDE_CBC_SHA           = 0x000A,
    CKCertificateChainCipher_SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA    = 0x000B,
    CKCertificateChainCipher_SSL_DH_DSS_WITH_DES_CBC_SHA             = 0x000C,
    CKCertificateChainCipher_SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA        = 0x000D,
    CKCertificateChainCipher_SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA    = 0x000E,
    CKCertificateChainCipher_SSL_DH_RSA_WITH_DES_CBC_SHA             = 0x000F,
    CKCertificateChainCipher_SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA        = 0x0010,
    CKCertificateChainCipher_SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA   = 0x0011,
    CKCertificateChainCipher_SSL_DHE_DSS_WITH_DES_CBC_SHA            = 0x0012,
    CKCertificateChainCipher_SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA       = 0x0013,
    CKCertificateChainCipher_SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA   = 0x0014,
    CKCertificateChainCipher_SSL_DHE_RSA_WITH_DES_CBC_SHA            = 0x0015,
    CKCertificateChainCipher_SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA       = 0x0016,
    CKCertificateChainCipher_SSL_DH_anon_EXPORT_WITH_RC4_40_MD5      = 0x0017,
    CKCertificateChainCipher_SSL_DH_anon_WITH_RC4_128_MD5            = 0x0018,
    CKCertificateChainCipher_SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA   = 0x0019,
    CKCertificateChainCipher_SSL_DH_anon_WITH_DES_CBC_SHA            = 0x001A,
    CKCertificateChainCipher_SSL_DH_anon_WITH_3DES_EDE_CBC_SHA       = 0x001B,
    CKCertificateChainCipher_SSL_FORTEZZA_DMS_WITH_NULL_SHA          = 0x001C,
    CKCertificateChainCipher_SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA  = 0x001D,
    CKCertificateChainCipher_TLS_RSA_WITH_AES_128_CBC_SHA            = 0x002F,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_128_CBC_SHA         = 0x0030,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_128_CBC_SHA         = 0x0031,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_128_CBC_SHA        = 0x0032,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_128_CBC_SHA        = 0x0033,
    CKCertificateChainCipher_TLS_DH_anon_WITH_AES_128_CBC_SHA        = 0x0034,
    CKCertificateChainCipher_TLS_RSA_WITH_AES_256_CBC_SHA            = 0x0035,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_256_CBC_SHA         = 0x0036,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_256_CBC_SHA         = 0x0037,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_256_CBC_SHA        = 0x0038,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_256_CBC_SHA        = 0x0039,
    CKCertificateChainCipher_TLS_DH_anon_WITH_AES_256_CBC_SHA        = 0x003A,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_NULL_SHA            = 0xC001,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_RC4_128_SHA         = 0xC002,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA    = 0xC003,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA     = 0xC004,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA     = 0xC005,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_NULL_SHA           = 0xC006,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_RC4_128_SHA        = 0xC007,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA   = 0xC008,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA    = 0xC009,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA    = 0xC00A,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_NULL_SHA              = 0xC00B,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_RC4_128_SHA           = 0xC00C,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA      = 0xC00D,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_128_CBC_SHA       = 0xC00E,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_256_CBC_SHA       = 0xC00F,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_NULL_SHA             = 0xC010,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_RC4_128_SHA          = 0xC011,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA     = 0xC012,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA      = 0xC013,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA      = 0xC014,
    CKCertificateChainCipher_TLS_ECDH_anon_WITH_NULL_SHA             = 0xC015,
    CKCertificateChainCipher_TLS_ECDH_anon_WITH_RC4_128_SHA          = 0xC016,
    CKCertificateChainCipher_TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA     = 0xC017,
    CKCertificateChainCipher_TLS_ECDH_anon_WITH_AES_128_CBC_SHA      = 0xC018,
    CKCertificateChainCipher_TLS_ECDH_anon_WITH_AES_256_CBC_SHA      = 0xC019,
    CKCertificateChainCipher_TLS_NULL_WITH_NULL_NULL                 = 0x0000,
    CKCertificateChainCipher_TLS_RSA_WITH_NULL_MD5                   = 0x0001,
    CKCertificateChainCipher_TLS_RSA_WITH_NULL_SHA                   = 0x0002,
    CKCertificateChainCipher_TLS_RSA_WITH_RC4_128_MD5                = 0x0004,
    CKCertificateChainCipher_TLS_RSA_WITH_RC4_128_SHA                = 0x0005,
    CKCertificateChainCipher_TLS_RSA_WITH_3DES_EDE_CBC_SHA           = 0x000A,
    CKCertificateChainCipher_TLS_RSA_WITH_NULL_SHA256                = 0x003B,
    CKCertificateChainCipher_TLS_RSA_WITH_AES_128_CBC_SHA256         = 0x003C,
    CKCertificateChainCipher_TLS_RSA_WITH_AES_256_CBC_SHA256         = 0x003D,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA        = 0x000D,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA        = 0x0010,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA       = 0x0013,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA       = 0x0016,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_128_CBC_SHA256      = 0x003E,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_128_CBC_SHA256      = 0x003F,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_128_CBC_SHA256     = 0x0040,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_128_CBC_SHA256     = 0x0067,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_256_CBC_SHA256      = 0x0068,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_256_CBC_SHA256      = 0x0069,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_256_CBC_SHA256     = 0x006A,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_256_CBC_SHA256     = 0x006B,
    CKCertificateChainCipher_TLS_DH_anon_WITH_RC4_128_MD5            = 0x0018,
    CKCertificateChainCipher_TLS_DH_anon_WITH_3DES_EDE_CBC_SHA       = 0x001B,
    CKCertificateChainCipher_TLS_DH_anon_WITH_AES_128_CBC_SHA256     = 0x006C,
    CKCertificateChainCipher_TLS_DH_anon_WITH_AES_256_CBC_SHA256     = 0x006D,
    CKCertificateChainCipher_TLS_PSK_WITH_RC4_128_SHA                = 0x008A,
    CKCertificateChainCipher_TLS_PSK_WITH_3DES_EDE_CBC_SHA           = 0x008B,
    CKCertificateChainCipher_TLS_PSK_WITH_AES_128_CBC_SHA            = 0x008C,
    CKCertificateChainCipher_TLS_PSK_WITH_AES_256_CBC_SHA            = 0x008D,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_RC4_128_SHA            = 0x008E,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA       = 0x008F,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_128_CBC_SHA        = 0x0090,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_256_CBC_SHA        = 0x0091,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_RC4_128_SHA            = 0x0092,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA       = 0x0093,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_128_CBC_SHA        = 0x0094,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_256_CBC_SHA        = 0x0095,
    CKCertificateChainCipher_TLS_PSK_WITH_NULL_SHA                   = 0x002C,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_NULL_SHA               = 0x002D,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_NULL_SHA               = 0x002E,
    CKCertificateChainCipher_TLS_RSA_WITH_AES_128_GCM_SHA256         = 0x009C,
    CKCertificateChainCipher_TLS_RSA_WITH_AES_256_GCM_SHA384         = 0x009D,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_128_GCM_SHA256     = 0x009E,
    CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_256_GCM_SHA384     = 0x009F,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_128_GCM_SHA256      = 0x00A0,
    CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_256_GCM_SHA384      = 0x00A1,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_128_GCM_SHA256     = 0x00A2,
    CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_256_GCM_SHA384     = 0x00A3,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_128_GCM_SHA256      = 0x00A4,
    CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_256_GCM_SHA384      = 0x00A5,
    CKCertificateChainCipher_TLS_DH_anon_WITH_AES_128_GCM_SHA256     = 0x00A6,
    CKCertificateChainCipher_TLS_DH_anon_WITH_AES_256_GCM_SHA384     = 0x00A7,
    CKCertificateChainCipher_TLS_PSK_WITH_AES_128_GCM_SHA256         = 0x00A8,
    CKCertificateChainCipher_TLS_PSK_WITH_AES_256_GCM_SHA384         = 0x00A9,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_128_GCM_SHA256     = 0x00AA,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_256_GCM_SHA384     = 0x00AB,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_128_GCM_SHA256     = 0x00AC,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_256_GCM_SHA384     = 0x00AD,
    CKCertificateChainCipher_TLS_PSK_WITH_AES_128_CBC_SHA256         = 0x00AE,
    CKCertificateChainCipher_TLS_PSK_WITH_AES_256_CBC_SHA384         = 0x00AF,
    CKCertificateChainCipher_TLS_PSK_WITH_NULL_SHA256                = 0x00B0,
    CKCertificateChainCipher_TLS_PSK_WITH_NULL_SHA384                = 0x00B1,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_128_CBC_SHA256     = 0x00B2,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_256_CBC_SHA384     = 0x00B3,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_NULL_SHA256            = 0x00B4,
    CKCertificateChainCipher_TLS_DHE_PSK_WITH_NULL_SHA384            = 0x00B5,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_128_CBC_SHA256     = 0x00B6,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_256_CBC_SHA384     = 0x00B7,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_NULL_SHA256            = 0x00B8,
    CKCertificateChainCipher_TLS_RSA_PSK_WITH_NULL_SHA384            = 0x00B9,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 = 0xC023,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 = 0xC024,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256  = 0xC025,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384  = 0xC026,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256   = 0xC027,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384   = 0xC028,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256    = 0xC029,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384    = 0xC02A,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 = 0xC02B,
    CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 = 0xC02C,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256  = 0xC02D,
    CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384  = 0xC02E,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256   = 0xC02F,
    CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384   = 0xC030,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256    = 0xC031,
    CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384    = 0xC032,
    CKCertificateChainCipher_TLS_EMPTY_RENEGOTIATION_INFO_SCSV       = 0x00FF,
    CKCertificateChainCipher_SSL_RSA_WITH_RC2_CBC_MD5                = 0xFF80,
    CKCertificateChainCipher_SSL_RSA_WITH_IDEA_CBC_MD5               = 0xFF81,
    CKCertificateChainCipher_SSL_RSA_WITH_DES_CBC_MD5                = 0xFF82,
    CKCertificateChainCipher_SSL_RSA_WITH_3DES_EDE_CBC_MD5           = 0xFF83,
    CKCertificateChainCipher_SSL_NO_SUCH_CIPHERSUITE                 = 0xFFFF
};

/**
 The domain for the certificate chain
 */
@property (strong, nonatomic, nonnull, readonly) NSString * domain;

/**
 The array of certificates belonging to the chain
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<CKCertificate *> * certificates;

/**
 The root of the certificate chain. Will be nil for chains with only one certificate (I.E. self signed roots)
 */
@property (strong, nonatomic, nullable, readonly) CKCertificate * rootCA;

/**
 The intermediate CA of the certificate chain. Will be nil for chains with only one certificate (I.E. self signed roots)
 */
@property (strong, nonatomic, nullable, readonly) CKCertificate * intermediateCA;

/**
 The server certificate in the chain.
 */
@property (strong, nonatomic, nullable, readonly) CKCertificate * server;

/**
 If the system trusts the certificate chain
 */
@property (nonatomic, readonly) CKCertificateChainTrustStatus trusted;

@property (nonatomic, readonly) CKCertificateChainCipher cipher;

/**
 *  Query the specified URL for its certificate chain.
 *
 *  @param URL      The URL to query. Must use the https scheme.
 *                  The port is optional and will default to 443.
 *  @param finished Called when finished with either an error or certificate chain.
 */
- (void) certificateChainFromURL:(NSURL * _Nonnull)URL finished:(void (^ _Nonnull)(NSError * _Nullable error, CKCertificateChain * _Nullable chain))finished;

@end
