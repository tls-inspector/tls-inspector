//
//  CKSecureTransportInspector+EnumValues.m
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

#import "CKSecureTransportInspector+EnumValues.h"

@implementation CKSecureTransportInspector (EnumValues)

- (NSString *) trustResultToString:(SecTrustResultType)result {
    switch (result) {
        case kSecTrustResultInvalid:
            return @"Invalid";
            break;
        case kSecTrustResultProceed:
            return @"Proceed";
            break;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        case kSecTrustResultConfirm:
            return @"Confirm";
            break;
#pragma clang diagnostic pop
        case kSecTrustResultDeny:
            return @"Deny";
            break;
        case kSecTrustResultUnspecified:
            return @"Unspecified";
            break;
        case kSecTrustResultRecoverableTrustFailure:
            return @"Recoverable Trust Failure";
            break;
        case kSecTrustResultFatalTrustFailure:
            return @"Fatal Trust Failure";
            break;
        case kSecTrustResultOtherError:
            return @"Other Error";
            break;
    }

    return @"Unknown";
}

- (NSString *) CiphersuiteToString:(SSLCipherSuite)cipher {
    switch (cipher) {
        case SSL_NULL_WITH_NULL_NULL:
            return @"NULL_WITH_NULL_NULL";
        case SSL_RSA_WITH_NULL_MD5:
            return @"RSA_WITH_NULL_MD5";
        case SSL_RSA_WITH_NULL_SHA:
            return @"RSA_WITH_NULL_SHA";
        case SSL_RSA_EXPORT_WITH_RC4_40_MD5:
            return @"RSA_EXPORT_WITH_RC4_40_MD5";
        case SSL_RSA_WITH_RC4_128_MD5:
            return @"RSA_WITH_RC4_128_MD5";
        case SSL_RSA_WITH_RC4_128_SHA:
            return @"RSA_WITH_RC4_128_SHA";
        case SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5:
            return @"RSA_EXPORT_WITH_RC2_CBC_40_MD5";
        case SSL_RSA_WITH_IDEA_CBC_SHA:
            return @"RSA_WITH_IDEA_CBC_SHA";
        case SSL_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_RSA_WITH_DES_CBC_SHA:
            return @"RSA_WITH_DES_CBC_SHA";
        case SSL_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_DSS_WITH_DES_CBC_SHA:
            return @"DH_DSS_WITH_DES_CBC_SHA";
        case SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"DH_DSS_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_RSA_WITH_DES_CBC_SHA:
            return @"DH_RSA_WITH_DES_CBC_SHA";
        case SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"DH_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"DHE_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DHE_DSS_WITH_DES_CBC_SHA:
            return @"DHE_DSS_WITH_DES_CBC_SHA";
        case SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"DHE_DSS_WITH_3DES_EDE_CBC_SHA";
        case SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"DHE_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DHE_RSA_WITH_DES_CBC_SHA:
            return @"DHE_RSA_WITH_DES_CBC_SHA";
        case SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"DHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_anon_EXPORT_WITH_RC4_40_MD5:
            return @"DH_anon_EXPORT_WITH_RC4_40_MD5";
        case SSL_DH_anon_WITH_RC4_128_MD5:
            return @"DH_anon_WITH_RC4_128_MD5";
        case SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH_anon_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_anon_WITH_DES_CBC_SHA:
            return @"DH_anon_WITH_DES_CBC_SHA";
        case SSL_DH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"DH_anon_WITH_3DES_EDE_CBC_SHA";
        case SSL_FORTEZZA_DMS_WITH_NULL_SHA:
            return @"FORTEZZA_DMS_WITH_NULL_SHA";
        case SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA:
            return @"FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA";
        case TLS_RSA_WITH_AES_128_CBC_SHA:
            return @"RSA_WITH_AES_128_CBC_SHA";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA:
            return @"DH_DSS_WITH_AES_128_CBC_SHA";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA:
            return @"DH_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA:
            return @"DHE_DSS_WITH_AES_128_CBC_SHA";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA:
            return @"DHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA:
            return @"DH_anon_WITH_AES_128_CBC_SHA";
        case TLS_RSA_WITH_AES_256_CBC_SHA:
            return @"RSA_WITH_AES_256_CBC_SHA";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA:
            return @"DH_DSS_WITH_AES_256_CBC_SHA";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA:
            return @"DH_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA:
            return @"DHE_DSS_WITH_AES_256_CBC_SHA";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA:
            return @"DHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA:
            return @"DH_anon_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_NULL_SHA:
            return @"ECDH_ECDSA_WITH_NULL_SHA";
        case TLS_ECDH_ECDSA_WITH_RC4_128_SHA:
            return @"ECDH_ECDSA_WITH_RC4_128_SHA";
        case TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDH_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDH_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_NULL_SHA:
            return @"ECDHE_ECDSA_WITH_NULL_SHA";
        case TLS_ECDHE_ECDSA_WITH_RC4_128_SHA:
            return @"ECDHE_ECDSA_WITH_RC4_128_SHA";
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_RSA_WITH_NULL_SHA:
            return @"ECDH_RSA_WITH_NULL_SHA";
        case TLS_ECDH_RSA_WITH_RC4_128_SHA:
            return @"ECDH_RSA_WITH_RC4_128_SHA";
        case TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDH_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDH_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_NULL_SHA:
            return @"ECDHE_RSA_WITH_NULL_SHA";
        case TLS_ECDHE_RSA_WITH_RC4_128_SHA:
            return @"ECDHE_RSA_WITH_RC4_128_SHA";
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_anon_WITH_NULL_SHA:
            return @"ECDH_anon_WITH_NULL_SHA";
        case TLS_ECDH_anon_WITH_RC4_128_SHA:
            return @"ECDH_anon_WITH_RC4_128_SHA";
        case TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH_anon_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_anon_WITH_AES_128_CBC_SHA:
            return @"ECDH_anon_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_anon_WITH_AES_256_CBC_SHA:
            return @"ECDH_anon_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA:
            return @"ECDHE_PSK_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA:
            return @"ECDHE_PSK_WITH_AES_256_CBC_SHA";
        case TLS_PSK_WITH_CHACHA20_POLY1305_SHA256:
            return @"PSK_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_RSA_WITH_NULL_SHA256:
            return @"RSA_WITH_NULL_SHA256";
        case TLS_RSA_WITH_AES_128_CBC_SHA256:
            return @"RSA_WITH_AES_128_CBC_SHA256";
        case TLS_RSA_WITH_AES_256_CBC_SHA256:
            return @"RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA256:
            return @"DH_DSS_WITH_AES_128_CBC_SHA256";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA256:
            return @"DH_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA256:
            return @"DHE_DSS_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"DHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA256:
            return @"DH_DSS_WITH_AES_256_CBC_SHA256";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA256:
            return @"DH_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA256:
            return @"DHE_DSS_WITH_AES_256_CBC_SHA256";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA256:
            return @"DHE_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA256:
            return @"DH_anon_WITH_AES_128_CBC_SHA256";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA256:
            return @"DH_anon_WITH_AES_256_CBC_SHA256";
        case TLS_PSK_WITH_RC4_128_SHA:
            return @"PSK_WITH_RC4_128_SHA";
        case TLS_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"PSK_WITH_3DES_EDE_CBC_SHA";
        case TLS_PSK_WITH_AES_128_CBC_SHA:
            return @"PSK_WITH_AES_128_CBC_SHA";
        case TLS_PSK_WITH_AES_256_CBC_SHA:
            return @"PSK_WITH_AES_256_CBC_SHA";
        case TLS_DHE_PSK_WITH_RC4_128_SHA:
            return @"DHE_PSK_WITH_RC4_128_SHA";
        case TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"DHE_PSK_WITH_3DES_EDE_CBC_SHA";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA:
            return @"DHE_PSK_WITH_AES_128_CBC_SHA";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA:
            return @"DHE_PSK_WITH_AES_256_CBC_SHA";
        case TLS_RSA_PSK_WITH_RC4_128_SHA:
            return @"RSA_PSK_WITH_RC4_128_SHA";
        case TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"RSA_PSK_WITH_3DES_EDE_CBC_SHA";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA:
            return @"RSA_PSK_WITH_AES_128_CBC_SHA";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA:
            return @"RSA_PSK_WITH_AES_256_CBC_SHA";
        case TLS_PSK_WITH_NULL_SHA:
            return @"PSK_WITH_NULL_SHA";
        case TLS_DHE_PSK_WITH_NULL_SHA:
            return @"DHE_PSK_WITH_NULL_SHA";
        case TLS_RSA_PSK_WITH_NULL_SHA:
            return @"RSA_PSK_WITH_NULL_SHA";
        case TLS_RSA_WITH_AES_128_GCM_SHA256:
            return @"RSA_WITH_AES_128_GCM_SHA256";
        case TLS_RSA_WITH_AES_256_GCM_SHA384:
            return @"RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"DHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"DHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DH_RSA_WITH_AES_128_GCM_SHA256:
            return @"DH_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DH_RSA_WITH_AES_256_GCM_SHA384:
            return @"DH_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_DSS_WITH_AES_128_GCM_SHA256:
            return @"DHE_DSS_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_DSS_WITH_AES_256_GCM_SHA384:
            return @"DHE_DSS_WITH_AES_256_GCM_SHA384";
        case TLS_DH_DSS_WITH_AES_128_GCM_SHA256:
            return @"DH_DSS_WITH_AES_128_GCM_SHA256";
        case TLS_DH_DSS_WITH_AES_256_GCM_SHA384:
            return @"DH_DSS_WITH_AES_256_GCM_SHA384";
        case TLS_DH_anon_WITH_AES_128_GCM_SHA256:
            return @"DH_anon_WITH_AES_128_GCM_SHA256";
        case TLS_DH_anon_WITH_AES_256_GCM_SHA384:
            return @"DH_anon_WITH_AES_256_GCM_SHA384";
        case TLS_PSK_WITH_AES_128_GCM_SHA256:
            return @"PSK_WITH_AES_128_GCM_SHA256";
        case TLS_PSK_WITH_AES_256_GCM_SHA384:
            return @"PSK_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_PSK_WITH_AES_128_GCM_SHA256:
            return @"DHE_PSK_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_PSK_WITH_AES_256_GCM_SHA384:
            return @"DHE_PSK_WITH_AES_256_GCM_SHA384";
        case TLS_RSA_PSK_WITH_AES_128_GCM_SHA256:
            return @"RSA_PSK_WITH_AES_128_GCM_SHA256";
        case TLS_RSA_PSK_WITH_AES_256_GCM_SHA384:
            return @"RSA_PSK_WITH_AES_256_GCM_SHA384";
        case TLS_PSK_WITH_AES_128_CBC_SHA256:
            return @"PSK_WITH_AES_128_CBC_SHA256";
        case TLS_PSK_WITH_AES_256_CBC_SHA384:
            return @"PSK_WITH_AES_256_CBC_SHA384";
        case TLS_PSK_WITH_NULL_SHA256:
            return @"PSK_WITH_NULL_SHA256";
        case TLS_PSK_WITH_NULL_SHA384:
            return @"PSK_WITH_NULL_SHA384";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA256:
            return @"DHE_PSK_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA384:
            return @"DHE_PSK_WITH_AES_256_CBC_SHA384";
        case TLS_DHE_PSK_WITH_NULL_SHA256:
            return @"DHE_PSK_WITH_NULL_SHA256";
        case TLS_DHE_PSK_WITH_NULL_SHA384:
            return @"DHE_PSK_WITH_NULL_SHA384";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA256:
            return @"RSA_PSK_WITH_AES_128_CBC_SHA256";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA384:
            return @"RSA_PSK_WITH_AES_256_CBC_SHA384";
        case TLS_RSA_PSK_WITH_NULL_SHA256:
            return @"RSA_PSK_WITH_NULL_SHA256";
        case TLS_RSA_PSK_WITH_NULL_SHA384:
            return @"RSA_PSK_WITH_NULL_SHA384";
        case TLS_AES_128_GCM_SHA256:
            return @"AES_128_GCM_SHA256";
        case TLS_AES_256_GCM_SHA384:
            return @"AES_256_GCM_SHA384";
        case TLS_CHACHA20_POLY1305_SHA256:
            return @"CHACHA20_POLY1305_SHA256";
        case TLS_AES_128_CCM_SHA256:
            return @"AES_128_CCM_SHA256";
        case TLS_AES_128_CCM_8_SHA256:
            return @"AES_128_CCM_8_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDH_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDH_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDH_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDH_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDH_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDH_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDH_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDH_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_EMPTY_RENEGOTIATION_INFO_SCSV:
            return @"EMPTY_RENEGOTIATION_INFO_SCSV";
        case SSL_RSA_WITH_RC2_CBC_MD5:
            return @"RSA_WITH_RC2_CBC_MD5";
        case SSL_RSA_WITH_IDEA_CBC_MD5:
            return @"RSA_WITH_IDEA_CBC_MD5";
        case SSL_RSA_WITH_DES_CBC_MD5:
            return @"RSA_WITH_DES_CBC_MD5";
        case SSL_RSA_WITH_3DES_EDE_CBC_MD5:
            return @"RSA_WITH_3DES_EDE_CBC_MD5";
        case SSL_NO_SUCH_CIPHERSUITE:
            return @"NO_SUCH_CIPHERSUITE";
    }

    return @"Unknown";
}

- (NSString *) protocolString:(int)protocol {
    switch (protocol) {
        case kSSLProtocol3:
            return @"SSLv3";
        case kTLSProtocol1:
            return @"TLS 1.0";
        case kTLSProtocol11:
            return @"TLS 1.1";
        case kTLSProtocol12:
            return @"TLS 1.2";
        case kTLSProtocol13:
            return @"TLS 1.3";
        case kDTLSProtocol1:
            return @"DTLS 1";
        case kSSLProtocol2:
            return @"SSLv2";
    }

    return @"Unknown";
}

@end
