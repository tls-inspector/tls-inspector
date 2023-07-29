//
//  CKNetworkFrameworkInspector+EnumValues.m
//
//  LGPLv3
//
//  Copyright (c) 2023 Ian Spence
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

#import "CKNetworkFrameworkInspector+EnumValues.h"

@implementation CKNetworkFrameworkInspector (EnumValues)

- (NSString *) sslVersionToString:(SSLProtocol)version API_AVAILABLE(ios(12.0)) {
    switch (version) {
        case kTLSProtocol1:
            return @"TLS 1.0";
        case kTLSProtocol11:
            return @"TLS 1.1";
        case kTLSProtocol12:
            return @"TLS 1.2";
        case kDTLSProtocol1:
            return @"DTLS 1.0";
        case kTLSProtocol13:
            return @"TLS 1.3";
        case kDTLSProtocol12:
            return @"DTLS 1.2";
        case kSSLProtocol2:
            return @"SSL 2.0";
        case kSSLProtocol3:
            return @"SSL 3.0";
        default:
            break;
    };

    PError(@"Unknown SSLProtocol: %u", version);
    return @"Unknown";
}

- (NSString *) tlsVersionToString:(tls_protocol_version_t)version API_AVAILABLE(ios(13.0)) {
    switch (version) {
        case tls_protocol_version_TLSv10:
            return @"TLS 1.0";
        case tls_protocol_version_TLSv11:
            return @"TLS 1.1";
        case tls_protocol_version_TLSv12:
            return @"TLS 1.2";
        case tls_protocol_version_TLSv13:
            return @"TLS 1.3";
        case tls_protocol_version_DTLSv10:
            return @"DTLS 1.0";
        case tls_protocol_version_DTLSv12:
            return @"DTLS 1.2";
    }

    PError(@"Unknown tls_protocol_version_t: %u", version);
    return @"Unknown";
}

- (NSString *) sslCipherSuiteToString:(SSLCipherSuite)suite API_AVAILABLE(ios(12.0)) {
    switch (suite) {
        case TLS_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_RSA_WITH_AES_128_CBC_SHA:
            return @"RSA_WITH_AES_128_CBC_SHA";
        case TLS_RSA_WITH_AES_256_CBC_SHA:
            return @"RSA_WITH_AES_256_CBC_SHA";
        case TLS_RSA_WITH_AES_128_GCM_SHA256:
            return @"RSA_WITH_AES_128_GCM_SHA256";
        case TLS_RSA_WITH_AES_256_GCM_SHA384:
            return @"RSA_WITH_AES_256_GCM_SHA384";
        case TLS_RSA_WITH_AES_128_CBC_SHA256:
            return @"RSA_WITH_AES_128_CBC_SHA256";
        case TLS_RSA_WITH_AES_256_CBC_SHA256:
            return @"RSA_WITH_AES_256_CBC_SHA256";
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_AES_128_GCM_SHA256:
            return @"AES_128_GCM_SHA256";
        case TLS_AES_256_GCM_SHA384:
            return @"AES_256_GCM_SHA384";
        case TLS_CHACHA20_POLY1305_SHA256:
            return @"CHACHA20_POLY1305_SHA256";
    }

    PError(@"Unknown SSLCipherSuite: %u", suite);
    return @"Unknown";
}

- (NSString *) tlsCipherSuiteToString:(tls_ciphersuite_t)suite API_AVAILABLE(ios(13.0)) {
    switch (suite) {
        case tls_ciphersuite_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"RSA_WITH_3DES_EDE_CBC_SHA";
        case tls_ciphersuite_RSA_WITH_AES_128_CBC_SHA:
            return @"RSA_WITH_AES_128_CBC_SHA";
        case tls_ciphersuite_RSA_WITH_AES_256_CBC_SHA:
            return @"RSA_WITH_AES_256_CBC_SHA";
        case tls_ciphersuite_RSA_WITH_AES_128_GCM_SHA256:
            return @"RSA_WITH_AES_128_GCM_SHA256";
        case tls_ciphersuite_RSA_WITH_AES_256_GCM_SHA384:
            return @"RSA_WITH_AES_256_GCM_SHA384";
        case tls_ciphersuite_RSA_WITH_AES_128_CBC_SHA256:
            return @"RSA_WITH_AES_128_CBC_SHA256";
        case tls_ciphersuite_RSA_WITH_AES_256_CBC_SHA256:
            return @"RSA_WITH_AES_256_CBC_SHA256";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA";
        case tls_ciphersuite_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case tls_ciphersuite_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA";
        case tls_ciphersuite_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA256";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA384";
        case tls_ciphersuite_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA256";
        case tls_ciphersuite_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA384";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_GCM_SHA256";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_GCM_SHA384";
        case tls_ciphersuite_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_GCM_SHA256";
        case tls_ciphersuite_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_GCM_SHA384";
        case tls_ciphersuite_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256";
        case tls_ciphersuite_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256";
        case tls_ciphersuite_AES_128_GCM_SHA256:
            return @"AES_128_GCM_SHA256";
        case tls_ciphersuite_AES_256_GCM_SHA384:
            return @"AES_256_GCM_SHA384";
        case tls_ciphersuite_CHACHA20_POLY1305_SHA256:
            return @"CHACHA20_POLY1305_SHA256";
    }

    PError(@"Unknown tls_ciphersuite_t: %u", suite);
    return @"Unknown";
}

@end
