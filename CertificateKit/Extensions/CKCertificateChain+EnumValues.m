//
//  CKCertificateChain+EnumValues.m
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

#import "CKCertificateChain+EnumValues.h"

@implementation CKCertificateChain (EnumValues)

- (NSString *) cipherString {
    switch (self.cipher) {
        case SSL_NULL_WITH_NULL_NULL:
            return @"NULL with NULL NULL";
        case SSL_RSA_WITH_NULL_MD5:
            return @"RSA with NULL MD5";
        case SSL_RSA_WITH_NULL_SHA:
            return @"RSA with NULL SHA";
        case SSL_RSA_EXPORT_WITH_RC4_40_MD5:
            return @"RSA EXPORT with RC4 40 MD5";
        case SSL_RSA_WITH_RC4_128_MD5:
            return @"RSA with RC4 128 MD5";
        case SSL_RSA_WITH_RC4_128_SHA:
            return @"RSA with RC4 128 SHA";
        case SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5:
            return @"RSA EXPORT with RC2 CBC 40 MD5";
        case SSL_RSA_WITH_IDEA_CBC_SHA:
            return @"RSA with IDEA CBC SHA";
        case SSL_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"RSA EXPORT with DES40 CBC SHA";
        case SSL_RSA_WITH_DES_CBC_SHA:
            return @"RSA with DES CBC SHA";
        case SSL_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"RSA with 3DES EDE CBC SHA";
        case SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH DSS EXPORT with DES40 CBC SHA";
        case SSL_DH_DSS_WITH_DES_CBC_SHA:
            return @"DH DSS with DES CBC SHA";
        case SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"DH DSS with 3DES EDE CBC SHA";
        case SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH RSA EXPORT with DES40 CBC SHA";
        case SSL_DH_RSA_WITH_DES_CBC_SHA:
            return @"DH RSA with DES CBC SHA";
        case SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"DH RSA with 3DES EDE CBC SHA";
        case SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"DHE DSS EXPORT with DES40 CBC SHA";
        case SSL_DHE_DSS_WITH_DES_CBC_SHA:
            return @"DHE DSS with DES CBC SHA";
        case SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"DHE DSS with 3DES EDE CBC SHA";
        case SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"DHE RSA EXPORT with DES40 CBC SHA";
        case SSL_DHE_RSA_WITH_DES_CBC_SHA:
            return @"DHE RSA with DES CBC SHA";
        case SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"DHE RSA with 3DES EDE CBC SHA";
        case SSL_DH_anon_EXPORT_WITH_RC4_40_MD5:
            return @"DH anon EXPORT with RC4 40 MD5";
        case SSL_DH_anon_WITH_RC4_128_MD5:
            return @"DH anon with RC4 128 MD5";
        case SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH anon EXPORT with DES40 CBC SHA";
        case SSL_DH_anon_WITH_DES_CBC_SHA:
            return @"DH anon with DES CBC SHA";
        case SSL_DH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"DH anon with 3DES EDE CBC SHA";
        case SSL_FORTEZZA_DMS_WITH_NULL_SHA:
            return @"FORTEZZA DMS with NULL SHA";
        case SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA:
            return @"FORTEZZA DMS with FORTEZZA CBC SHA";
        case TLS_RSA_WITH_AES_128_CBC_SHA:
            return @"RSA with AES 128 CBC SHA";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA:
            return @"DH DSS with AES 128 CBC SHA";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA:
            return @"DH RSA with AES 128 CBC SHA";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA:
            return @"DHE DSS with AES 128 CBC SHA";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA:
            return @"DHE RSA with AES 128 CBC SHA";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA:
            return @"DH anon with AES 128 CBC SHA";
        case TLS_RSA_WITH_AES_256_CBC_SHA:
            return @"RSA with AES 256 CBC SHA";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA:
            return @"DH DSS with AES 256 CBC SHA";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA:
            return @"DH RSA with AES 256 CBC SHA";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA:
            return @"DHE DSS with AES 256 CBC SHA";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA:
            return @"DHE RSA with AES 256 CBC SHA";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA:
            return @"DH anon with AES 256 CBC SHA";
        case TLS_ECDH_ECDSA_WITH_NULL_SHA:
            return @"ECDH ECDSA with NULL SHA";
        case TLS_ECDH_ECDSA_WITH_RC4_128_SHA:
            return @"ECDH ECDSA with RC4 128 SHA";
        case TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH ECDSA with 3DES EDE CBC SHA";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDH ECDSA with AES 128 CBC SHA";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDH ECDSA with AES 256 CBC SHA";
        case TLS_ECDHE_ECDSA_WITH_NULL_SHA:
            return @"ECDHE ECDSA with NULL SHA";
        case TLS_ECDHE_ECDSA_WITH_RC4_128_SHA:
            return @"ECDHE ECDSA with RC4 128 SHA";
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE ECDSA with 3DES EDE CBC SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE ECDSA with AES 128 CBC SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE ECDSA with AES 256 CBC SHA";
        case TLS_ECDH_RSA_WITH_NULL_SHA:
            return @"ECDH RSA with NULL SHA";
        case TLS_ECDH_RSA_WITH_RC4_128_SHA:
            return @"ECDH RSA with RC4 128 SHA";
        case TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH RSA with 3DES EDE CBC SHA";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDH RSA with AES 128 CBC SHA";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDH RSA with AES 256 CBC SHA";
        case TLS_ECDHE_RSA_WITH_NULL_SHA:
            return @"ECDHE RSA with NULL SHA";
        case TLS_ECDHE_RSA_WITH_RC4_128_SHA:
            return @"ECDHE RSA with RC4 128 SHA";
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE RSA with 3DES EDE CBC SHA";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE RSA with AES 128 CBC SHA";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE RSA with AES 256 CBC SHA";
        case TLS_ECDH_anon_WITH_NULL_SHA:
            return @"ECDH anon with NULL SHA";
        case TLS_ECDH_anon_WITH_RC4_128_SHA:
            return @"ECDH anon with RC4 128 SHA";
        case TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH anon with 3DES EDE CBC SHA";
        case TLS_ECDH_anon_WITH_AES_128_CBC_SHA:
            return @"ECDH anon with AES 128 CBC SHA";
        case TLS_ECDH_anon_WITH_AES_256_CBC_SHA:
            return @"ECDH anon with AES 256 CBC SHA";
        case TLS_RSA_WITH_NULL_SHA256:
            return @"RSA with NULL SHA256";
        case TLS_RSA_WITH_AES_128_CBC_SHA256:
            return @"RSA with AES 128 CBC SHA256";
        case TLS_RSA_WITH_AES_256_CBC_SHA256:
            return @"RSA with AES 256 CBC SHA256";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA256:
            return @"DH DSS with AES 128 CBC SHA256";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA256:
            return @"DH RSA with AES 128 CBC SHA256";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA256:
            return @"DHE DSS with AES 128 CBC SHA256";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"DHE RSA with AES 128 CBC SHA256";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA256:
            return @"DH DSS with AES 256 CBC SHA256";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA256:
            return @"DH RSA with AES 256 CBC SHA256";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA256:
            return @"DHE DSS with AES 256 CBC SHA256";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA256:
            return @"DHE RSA with AES 256 CBC SHA256";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA256:
            return @"DH anon with AES 128 CBC SHA256";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA256:
            return @"DH anon with AES 256 CBC SHA256";
        case TLS_PSK_WITH_RC4_128_SHA:
            return @"PSK with RC4 128 SHA";
        case TLS_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"PSK with 3DES EDE CBC SHA";
        case TLS_PSK_WITH_AES_128_CBC_SHA:
            return @"PSK with AES 128 CBC SHA";
        case TLS_PSK_WITH_AES_256_CBC_SHA:
            return @"PSK with AES 256 CBC SHA";
        case TLS_DHE_PSK_WITH_RC4_128_SHA:
            return @"DHE PSK with RC4 128 SHA";
        case TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"DHE PSK with 3DES EDE CBC SHA";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA:
            return @"DHE PSK with AES 128 CBC SHA";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA:
            return @"DHE PSK with AES 256 CBC SHA";
        case TLS_RSA_PSK_WITH_RC4_128_SHA:
            return @"RSA PSK with RC4 128 SHA";
        case TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"RSA PSK with 3DES EDE CBC SHA";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA:
            return @"RSA PSK with AES 128 CBC SHA";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA:
            return @"RSA PSK with AES 256 CBC SHA";
        case TLS_PSK_WITH_NULL_SHA:
            return @"PSK with NULL SHA";
        case TLS_DHE_PSK_WITH_NULL_SHA:
            return @"DHE PSK with NULL SHA";
        case TLS_RSA_PSK_WITH_NULL_SHA:
            return @"RSA PSK with NULL SHA";
        case TLS_RSA_WITH_AES_128_GCM_SHA256:
            return @"RSA with AES 128 GCM SHA256";
        case TLS_RSA_WITH_AES_256_GCM_SHA384:
            return @"RSA with AES 256 GCM SHA384";
        case TLS_DHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"DHE RSA with AES 128 GCM SHA256";
        case TLS_DHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"DHE RSA with AES 256 GCM SHA384";
        case TLS_DH_RSA_WITH_AES_128_GCM_SHA256:
            return @"DH RSA with AES 128 GCM SHA256";
        case TLS_DH_RSA_WITH_AES_256_GCM_SHA384:
            return @"DH RSA with AES 256 GCM SHA384";
        case TLS_DHE_DSS_WITH_AES_128_GCM_SHA256:
            return @"DHE DSS with AES 128 GCM SHA256";
        case TLS_DHE_DSS_WITH_AES_256_GCM_SHA384:
            return @"DHE DSS with AES 256 GCM SHA384";
        case TLS_DH_DSS_WITH_AES_128_GCM_SHA256:
            return @"DH DSS with AES 128 GCM SHA256";
        case TLS_DH_DSS_WITH_AES_256_GCM_SHA384:
            return @"DH DSS with AES 256 GCM SHA384";
        case TLS_DH_anon_WITH_AES_128_GCM_SHA256:
            return @"DH anon with AES 128 GCM SHA256";
        case TLS_DH_anon_WITH_AES_256_GCM_SHA384:
            return @"DH anon with AES 256 GCM SHA384";
        case TLS_PSK_WITH_AES_128_GCM_SHA256:
            return @"PSK with AES 128 GCM SHA256";
        case TLS_PSK_WITH_AES_256_GCM_SHA384:
            return @"PSK with AES 256 GCM SHA384";
        case TLS_DHE_PSK_WITH_AES_128_GCM_SHA256:
            return @"DHE PSK with AES 128 GCM SHA256";
        case TLS_DHE_PSK_WITH_AES_256_GCM_SHA384:
            return @"DHE PSK with AES 256 GCM SHA384";
        case TLS_RSA_PSK_WITH_AES_128_GCM_SHA256:
            return @"RSA PSK with AES 128 GCM SHA256";
        case TLS_RSA_PSK_WITH_AES_256_GCM_SHA384:
            return @"RSA PSK with AES 256 GCM SHA384";
        case TLS_PSK_WITH_AES_128_CBC_SHA256:
            return @"PSK with AES 128 CBC SHA256";
        case TLS_PSK_WITH_AES_256_CBC_SHA384:
            return @"PSK with AES 256 CBC SHA384";
        case TLS_PSK_WITH_NULL_SHA256:
            return @"PSK with NULL SHA256";
        case TLS_PSK_WITH_NULL_SHA384:
            return @"PSK with NULL SHA384";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA256:
            return @"DHE PSK with AES 128 CBC SHA256";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA384:
            return @"DHE PSK with AES 256 CBC SHA384";
        case TLS_DHE_PSK_WITH_NULL_SHA256:
            return @"DHE PSK with NULL SHA256";
        case TLS_DHE_PSK_WITH_NULL_SHA384:
            return @"DHE PSK with NULL SHA384";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA256:
            return @"RSA PSK with AES 128 CBC SHA256";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA384:
            return @"RSA PSK with AES 256 CBC SHA384";
        case TLS_RSA_PSK_WITH_NULL_SHA256:
            return @"RSA PSK with NULL SHA256";
        case TLS_RSA_PSK_WITH_NULL_SHA384:
            return @"RSA PSK with NULL SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE ECDSA with AES 128 CBC SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE ECDSA with AES 256 CBC SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDH ECDSA with AES 128 CBC SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDH ECDSA with AES 256 CBC SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE RSA with AES 128 CBC SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE RSA with AES 256 CBC SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDH RSA with AES 128 CBC SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDH RSA with AES 256 CBC SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE ECDSA with AES 128 GCM SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE ECDSA with AES 256 GCM SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDH ECDSA with AES 128 GCM SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDH ECDSA with AES 256 GCM SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE RSA with AES 128 GCM SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE RSA with AES 256 GCM SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDH RSA with AES 128 GCM SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDH RSA with AES 256 GCM SHA384";
        case TLS_EMPTY_RENEGOTIATION_INFO_SCSV:
            return @"EMPTY RENEGOTIATION INFO SCSV";
        case SSL_RSA_WITH_RC2_CBC_MD5:
            return @"RSA with RC2 CBC MD5";
        case SSL_RSA_WITH_IDEA_CBC_MD5:
            return @"RSA with IDEA CBC MD5";
        case SSL_RSA_WITH_DES_CBC_MD5:
            return @"RSA with DES CBC MD5";
        case SSL_RSA_WITH_3DES_EDE_CBC_MD5:
            return @"RSA with 3DES EDE CBC MD5";
        case SSL_NO_SUCH_CIPHERSUITE:
            return @"NO SUCH CIPHERSUITE";
    }

    return @"Unknown";
}

- (NSString *) protocolString {
    switch (self.protocol) {
        case kSSLProtocolUnknown:
            return @"Unknown";
        case kSSLProtocol3:
            return @"SSLv3";
        case kTLSProtocol1:
            return @"TLS 1.0";
        case kTLSProtocol11:
            return @"TLS 1.1";
        case kTLSProtocol12:
            return @"TLS 1.2";
        case kDTLSProtocol1:
            return @"DTLS 1";
        case kSSLProtocol2:
            return @"SSLv2";
        case kSSLProtocol3Only:
            return @"SSLv3 (Only)";
        case kTLSProtocol1Only:
            return @"TLS 1.0 (Only)";
        case kSSLProtocolAll:
            return @"All";
    }

    return @"Unknown";
}

@end
