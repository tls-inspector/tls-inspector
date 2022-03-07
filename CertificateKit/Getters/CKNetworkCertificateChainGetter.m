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
#import "CKCRLManager.h"
#import "CKOCSPManager.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <mach/mach_time.h>

@interface CKNetworkCertificateChainGetter ()

@property (strong, nonatomic) CKCertificateChain * chain;
@property (strong, nonatomic) CKGetterParameters * parameters;

@end

@implementation CKNetworkCertificateChainGetter

- (void) performTaskWithParameters:(CKGetterParameters *)parameters API_AVAILABLE(ios(12.0)) {
    uint64_t startTime = mach_absolute_time();
    PDebug(@"Getting certificate chain with NetworkFramework");

    self.parameters = parameters;
    self.chain = [CKCertificateChain new];
    self.chain.domain = parameters.hostAddress;

    const char * portStr = [[NSString alloc] initWithFormat:@"%i", parameters.port].UTF8String;
    nw_endpoint_t endpoint = nw_endpoint_create_host(parameters.ipAddress.UTF8String, portStr);
    long __block numberOfCertificates = 0L;

    dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("com.tlsinspector.CertificateKit.CKNetworkCertificateChainGetter", NULL);

    // TCP configuration
    nw_parameters_configure_protocol_block_t configure_tcp = ^(nw_protocol_options_t tcp_options) {
        nw_tcp_options_set_connection_timeout(tcp_options, 5);
    };

    // TLS configuration
    nw_parameters_configure_protocol_block_t configure_tls = ^(nw_protocol_options_t tls_options) {
        PDebug(@"Starting TLS configuration");
        sec_protocol_options_t sec_options = nw_tls_copy_sec_protocol_options(tls_options);
        sec_protocol_options_set_tls_ocsp_enabled(sec_options, false); // Don't do OCSP because we do it ourselves
        sec_protocol_options_set_tls_server_name(sec_options, parameters.hostAddress.UTF8String);
        sec_protocol_options_set_tls_resumption_enabled(sec_options, false); // Don't reuse sessions otherwise the verify block is not called
        sec_protocol_options_set_verify_block(sec_options, ^(sec_protocol_metadata_t  _Nonnull metadata, sec_trust_t  _Nonnull trust_ref, sec_protocol_verify_complete_t  _Nonnull complete) {
            PDebug(@"Starting TLS verification");
            // Determine trust and get the root certificate
            SecTrustRef trust = sec_trust_copy_ref(trust_ref);
            SecTrustResultType trustStatus;
            SecTrustGetTrustResult(trust, &trustStatus);
            numberOfCertificates = SecTrustGetCertificateCount(trust);
            if (numberOfCertificates > CERTIFICATE_CHAIN_MAXIMUM) {
                PError(@"Server returned too many certificates. Count: %li, Max: %i", numberOfCertificates, CERTIFICATE_CHAIN_MAXIMUM);
                self.finished = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
                    [self.delegate getter:self failedTaskWithError:MAKE_ERROR(-1, @"Too many certificates from server")];
                }
                return;
            }

            NSMutableArray<CKCertificate *> * certificates = [NSMutableArray arrayWithCapacity:numberOfCertificates];
            for (int i = 0; i < numberOfCertificates; i++) {
                SecCertificateRef certificateRef = SecTrustGetCertificateAtIndex(trust, i);
                CKCertificate * certificate = [CKCertificate fromSecCertificateRef:certificateRef];
                [certificates addObject:certificate];
            }
            self.chain.certificates = certificates;

            self.chain.server = certificates[0];
            if (certificates.count > 2) {
                self.chain.rootCA = [certificates lastObject];
                self.chain.rootCA.isRootCA = YES;
                self.chain.intermediateCA = [certificates objectAtIndex:1];
            } else if (certificates.count == 2) {
                self.chain.rootCA = [certificates lastObject];
                self.chain.rootCA.isRootCA = YES;
            }

            if (certificates.count > 1) {
                self.chain.server.revoked = [self getRevokedInformationForCertificate:certificates[0] issuer:certificates[1]];
            }
            if (certificates.count > 2) {
                self.chain.intermediateCA.revoked = [self getRevokedInformationForCertificate:certificates[1] issuer:certificates[2]];
            }

            if (trustStatus == kSecTrustResultUnspecified) {
                self.chain.trusted = CKCertificateChainTrustStatusTrusted;
            } else if (trustStatus == kSecTrustResultProceed) {
                self.chain.trusted = CKCertificateChainTrustStatusLocallyTrusted;
            } else {
                [self.chain determineTrustFailureReason];
            }

            NSString * protoVersionStr;
            NSString * suiteStr;

            if (@available(iOS 13, *)) {
                tls_protocol_version_t proto_v = sec_protocol_metadata_get_negotiated_tls_protocol_version(metadata);
                tls_ciphersuite_t suite = sec_protocol_metadata_get_negotiated_tls_ciphersuite(metadata);

                protoVersionStr = [self tlsVersionToString:proto_v];
                suiteStr = [self tlsCipherSuiteToString:suite];
            } else {
                SSLProtocol proto_v = sec_protocol_metadata_get_negotiated_protocol_version(metadata);
                SSLCipherSuite suite = sec_protocol_metadata_get_negotiated_ciphersuite(metadata);

                protoVersionStr = [self sslVersionToString:proto_v];
                suiteStr = [self sslCipherSuiteToString:suite];
            }

            if (protoVersionStr == nil) {
                protoVersionStr = @"Unknown";
            }
            if (suiteStr == nil) {
                suiteStr = @"Unknown";
            }

            self.chain.protocol = protoVersionStr;
            self.chain.cipherSuite = suiteStr;

            complete(true);
        }, nw_dispatch_queue);
    };

    nw_parameters_t nwparameters = nw_parameters_create_secure_tcp(configure_tls, configure_tcp);
    nw_protocol_stack_t protocol_stack = nw_parameters_copy_default_protocol_stack(nwparameters);
    nw_protocol_options_t ip_options = nw_protocol_stack_copy_internet_protocol(protocol_stack);
    if (parameters.ipVersion == IP_VERSION_IPV4) {
        nw_ip_options_set_version(ip_options, nw_ip_version_4);
    } else if (parameters.ipVersion == IP_VERSION_IPV6) {
        nw_ip_options_set_version(ip_options, nw_ip_version_6);
    }

    nw_connection_t connection = nw_connection_create(endpoint, nwparameters);
    nw_connection_set_queue(connection, nw_dispatch_queue);
    nw_connection_set_state_changed_handler(connection, ^(nw_connection_state_t state, nw_error_t error) {
        switch (state) {
            case nw_connection_state_invalid:
                PDebug(@"Event: nw_connection_state_invalid");
                break;
            case nw_connection_state_waiting:
                PDebug(@"Event: nw_connection_state_waiting");
                PError(@"nw_connection failed: %@", error.description);
                self.finished = YES;
                self.successful = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
                    int errorCode = -1;
                    NSString * errorDescription = @"timed out";
                    if (error != nil) {
                        errorCode = nw_error_get_error_code(error);
                        errorDescription = error.debugDescription;
                    } else {
                        PError(@"nw_connection_state_waiting with no error");
                    }
                    [self.delegate getter:self failedTaskWithError:[NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkCertificateChainGetter" code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorDescription}]];
                }
                nw_connection_cancel(connection);
                break;
            case nw_connection_state_preparing:
                PDebug(@"Event: nw_connection_state_preparing");
                break;
            case nw_connection_state_ready:
                PDebug(@"Event: nw_connection_state_ready");
                if (numberOfCertificates <= 0) {
                    PError(@"No certificates returned");
                    self.finished = YES;
                    self.successful = NO;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
                        [self.delegate getter:self failedTaskWithError:[NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkCertificateChainGetter" code:500 userInfo:@{NSLocalizedDescriptionKey: @"No certificates returned"}]];
                    }
                    nw_connection_cancel(connection);
                    break;
                }

                self.chain.remoteAddress = [CKSocketUtils remoteAddressFromEndpoint:nw_path_copy_effective_remote_endpoint(nw_connection_copy_current_path(connection))];
                PDebug(@"NetworkFramework getter successful");
                PDebug(@"Connected to '%@' (%@), Protocol version: %@, Ciphersuite: %@. Server returned %li certificates", parameters.hostAddress, self.chain.remoteAddress, self.chain.protocol, self.chain.cipherSuite, numberOfCertificates);

                self.finished = YES;
                self.successful = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(getter:finishedTaskWithResult:)]) {
                    [self.delegate getter:self finishedTaskWithResult:self.chain];
                }

                uint64_t endTime = mach_absolute_time();
                if (CKLogging.sharedInstance.level <= CKLoggingLevelDebug) {
                    uint64_t elapsedTime = endTime - startTime;
                    static double ticksToNanoseconds = 0.0;
                    if (0.0 == ticksToNanoseconds) {
                        mach_timebase_info_data_t timebase;
                        mach_timebase_info(&timebase);
                        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
                    }
                    double elapsedTimeInNanoseconds = elapsedTime * ticksToNanoseconds;
                    PDebug(@"NetworkFramework getter collected certificate information in %fns", elapsedTimeInNanoseconds);
                }

                nw_connection_cancel(connection);
                PDebug(@"Cancelling connection - goodbye!");
                break;
            case nw_connection_state_failed:
                PDebug(@"Event: nw_connection_state_failed");
                PError(@"nw_connection failed: %@", error.description);
                self.finished = YES;
                self.successful = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
                    [self.delegate getter:self failedTaskWithError:[NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkCertificateChainGetter" code:nw_error_get_error_code(error) userInfo:@{NSLocalizedDescriptionKey: error.debugDescription}]];
                }
                break;
            case nw_connection_state_cancelled:
                PDebug(@"Event: nw_connection_state_cancelled");
                break;
            default:
                PError(@"Unknown nw_connection_state: %u", state);
                break;
        }
    });
    nw_connection_start(connection);
}

- (CKRevoked *) getRevokedInformationForCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer {
    CKOCSPResponse * ocspResponse;
    CKCRLResponse * crlResponse;
    NSError * ocspError;
    NSError * crlError;

    if (self.parameters.checkOCSP) {
        [[CKOCSPManager sharedManager] queryCertificate:certificate issuer:issuer response:&ocspResponse error:&ocspError];
        if (ocspError != nil) {
            PError(@"OCSP Error: %@", ocspError.description);
        }
    }
    if (self.parameters.checkCRL) {
        [[CKCRLManager sharedManager] queryCertificate:certificate issuer:issuer response:&crlResponse error:&crlError];
        if (crlError != nil) {
            PError(@"CRL Error: %@", crlError.description);
        }
    }
    return [CKRevoked fromOCSPResponse:ocspResponse andCRLResponse:crlResponse];
}

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
