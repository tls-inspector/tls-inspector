//
//  CKNetworkCertificateChainGetter.m
//
//  LGPLv3
//
//  Copyright (c) 2020 Ian Spence
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

@import Network;
#import "CKNetworkCertificateChainGetter.h"
#import "CKSocketUtils.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>

@interface CKNetworkCertificateChainGetter ()

@property (strong, nonatomic) CKCertificateChain * chain;

@end

@implementation CKNetworkCertificateChainGetter

- (void) performTaskForURL:(NSURL *)url {
    self.chain = [CKCertificateChain new];
    self.chain.domain = url.host;
    self.chain.url = url;

    // TODO: Figure out if we can not have this entire thing be wrapped in an availability block
    if (@available(iOS 12, *)) {
        const char * host = url.host.UTF8String;
        unsigned int port = url.port != nil ? [url.port unsignedIntValue] : 443;
        const char * portStr = [[NSString alloc] initWithFormat:@"%i", port].UTF8String;
        nw_endpoint_t endpoint = nw_endpoint_create_host(host, portStr);

        dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("com.tlsinspector.CertificateKit.CKNetworkCertificateChainGetter", NULL);

        nw_parameters_configure_protocol_block_t configure_tls = ^(nw_protocol_options_t tls_options) {
            sec_protocol_options_t sec_options = nw_tls_copy_sec_protocol_options(tls_options);

            if (@available(iOS 13, *)) {
                sec_protocol_options_append_tls_ciphersuite(sec_options, (SSLCipherSuite)TLS_CHACHA20_POLY1305_SHA256);
            }

            sec_protocol_options_set_verify_block(sec_options, ^(sec_protocol_metadata_t  _Nonnull metadata, sec_trust_t  _Nonnull trust_ref, sec_protocol_verify_complete_t  _Nonnull complete) {
                // Determine trust and get the root certificate
                SecTrustRef trust = sec_trust_copy_ref(trust_ref);
                SecTrustResultType trustStatus;
                SecTrustEvaluate(trust, &trustStatus);
                long count = SecTrustGetCertificateCount(trust);
                NSMutableArray<CKCertificate *> * certificates = [NSMutableArray arrayWithCapacity:count];
                for (int i = 0; i < count; i++) {
                    SecCertificateRef certificateRef = SecTrustGetCertificateAtIndex(trust, i);
                    CKCertificate * certificate = [CKCertificate fromSecCertificateRef:certificateRef];
                    [certificates addObject:certificate];
                }
                self.chain.certificates = certificates;
                
                if (trustStatus == kSecTrustResultUnspecified) {
                    self.chain.trusted = CKCertificateChainTrustStatusTrusted;
                } else if (trustStatus == kSecTrustResultProceed) {
                    self.chain.trusted = CKCertificateChainTrustStatusLocallyTrusted;
                } else {
                    [self.chain determineTrustFailureReason];
                }

                tls_protocol_version_t proto_v;
                tls_ciphersuite_t suite;

                if (@available(iOS 13, *)) {
                    proto_v = sec_protocol_metadata_get_negotiated_tls_protocol_version(metadata);
                    suite = sec_protocol_metadata_get_negotiated_tls_ciphersuite(metadata);
                } else {
                    proto_v = sec_protocol_metadata_get_negotiated_protocol_version(metadata);
                    suite = sec_protocol_metadata_get_negotiated_ciphersuite(metadata);
                }
                self.chain.protocol = [self tlsVersionToString:proto_v];
                self.chain.cipherSuite = [self tlsCipherSuiteToString:suite];

                complete(true);
            }, nw_dispatch_queue);
        };
        
        nw_parameters_t parameters = nw_parameters_create_secure_tcp(configure_tls, NW_PARAMETERS_DEFAULT_CONFIGURATION);
        nw_connection_t connection = nw_connection_create(endpoint, parameters);
        nw_connection_set_queue(connection, nw_dispatch_queue);
        nw_connection_set_state_changed_handler(connection, ^(nw_connection_state_t state, nw_error_t error) {
            switch (state) {
                case nw_connection_state_invalid:
                    NSLog(@"Event: nw_connection_state_invalid");
                    break;
                case nw_connection_state_waiting:
                    NSLog(@"Event: nw_connection_state_waiting");
                    break;
                case nw_connection_state_preparing:
                    NSLog(@"Event: nw_connection_state_preparing");
                    break;
                case nw_connection_state_ready:
                    NSLog(@"Event: nw_connection_state_ready");
                    break;
                case nw_connection_state_failed:
                    NSLog(@"Event: nw_connection_state_failed");
                    break;
                case nw_connection_state_cancelled:
                    NSLog(@"Event: nw_connection_state_cancelled");
                    break;
                default:
                    NSLog(@"Unknown event?");
                    break;
            }

            if (state == nw_connection_state_failed) {
                PError(@"nw_connection failed: %@", error.description);
                self.finished = YES;
                self.successful = NO;
                [self.delegate getter:self failedTaskWithError:[NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkCertificateChainGetter" code:nw_error_get_error_code(error) userInfo:@{NSLocalizedDescriptionKey: error.debugDescription}]];
            } else if (state == nw_connection_state_ready) {
                self.chain.remoteAddress = [CKSocketUtils remoteAddressFromEndpoint:nw_path_copy_effective_remote_endpoint(nw_connection_copy_current_path(connection))];

                self.finished = YES;
                self.successful = YES;
                [self.delegate getter:self finishedTaskWithResult:self.chain];
                
                nw_connection_cancel(connection);
            }
        });
        nw_connection_start(connection);
    }
}

- (NSString *) tlsVersionToString:(tls_protocol_version_t)version {
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
    
    return @"Unknown";
}

- (NSString *) tlsCipherSuiteToString:(tls_ciphersuite_t)suite {
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
    
    return @"Unknown";
}

@end
