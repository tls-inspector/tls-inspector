//
//  CKNetworkFrameworkInspector.m
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
#import "CKNetworkFrameworkInspector.h"
#import "CKNetworkFrameworkInspector+EnumValues.h"
#import "CKSocketUtils.h"
#import "CKCRLManager.h"
#import "CKOCSPManager.h"
#import "CKHTTPClient.h"
#import "CKHTTPServerInfo+Private.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <mach/mach_time.h>

@interface CKNetworkFrameworkInspector ()

@property (strong, nonatomic) CKCertificateChain * chain;
@property (strong, nonatomic) CKInspectParameters * parameters;

@end

@implementation CKNetworkFrameworkInspector

- (void) performTaskWithParameters:(CKInspectParameters *)parameters {}

- (void) executeWithParameters:(CKInspectParameters *)parameters completed:(void (^)(CKInspectResponse *, NSError *))completed {
    uint64_t startTime = mach_absolute_time();
    PDebug(@"Getting certificate chain with NetworkFramework");

    self.parameters = parameters;
    self.chain = [CKCertificateChain new];
    self.chain.domain = parameters.hostAddress;

    const char * portStr = [[NSString alloc] initWithFormat:@"%i", parameters.port].UTF8String;
    nw_endpoint_t endpoint = nw_endpoint_create_host(parameters.ipAddress.UTF8String, portStr);
    long __block numberOfCertificates = 0L;

    dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("com.tlsinspector.CertificateKit.CKNetworkFrameworkInspector", NULL);

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
                completed(nil, MAKE_ERROR(-1, @"Too many certificates from server"));
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

            [self.chain checkAuthorityTrust];

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
            case nw_connection_state_invalid: {
                PDebug(@"Event: nw_connection_state_invalid");
                break;
            }
            case nw_connection_state_waiting: {
                PDebug(@"Event: nw_connection_state_waiting");
                PError(@"nw_connection failed: %@", error.description);
                int errorCode = -1;
                NSString * errorDescription = @"timed out";
                if (error != nil) {
                    errorCode = nw_error_get_error_code(error);
                    errorDescription = error.debugDescription;
                } else {
                    PError(@"nw_connection_state_waiting with no error");
                }
                completed(nil, [NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkFrameworkInspector" code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorDescription}]);
                nw_connection_cancel(connection);
                break;
            }
            case nw_connection_state_preparing: {
                PDebug(@"Event: nw_connection_state_preparing");
                break;
            }
            case nw_connection_state_ready: {
                PDebug(@"Event: nw_connection_state_ready");
                if (numberOfCertificates <= 0) {
                    PError(@"No certificates returned");
                    completed(nil, [NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkFrameworkInspector" code:500 userInfo:@{NSLocalizedDescriptionKey: @"No certificates returned"}]);
                    nw_connection_cancel(connection);
                    break;
                }

                self.chain.remoteAddress = [CKSocketUtils remoteAddressFromEndpoint:nw_path_copy_effective_remote_endpoint(nw_connection_copy_current_path(connection))];
                PDebug(@"NetworkFramework getter successful");
                PDebug(@"Connected to '%@' (%@), Protocol version: %@, Ciphersuite: %@. Server returned %li certificates", parameters.hostAddress, self.chain.remoteAddress, self.chain.protocol, self.chain.cipherSuite, numberOfCertificates);
                [self getHeadersForConnection:connection queue:nw_dispatch_queue completed:^(CKHTTPResponse * response) {
                    CKHTTPServerInfo * serverInfo;
                    if (response != nil) {
                        serverInfo = [CKHTTPServerInfo fromHTTPResponse:response];
                    }
                    completed([CKInspectResponse responseWithCertificateChain:self.chain httpServerInfo:serverInfo], nil);

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
                }];
                break;
            }
            case nw_connection_state_failed: {
                PDebug(@"Event: nw_connection_state_failed");
                PError(@"nw_connection failed: %@", error.description);
                completed(nil, [NSError errorWithDomain:@"com.tlsinspector.CertificateKit.CKNetworkFrameworkInspector" code:nw_error_get_error_code(error) userInfo:@{NSLocalizedDescriptionKey: error.debugDescription}]);
                break;
            }
            case nw_connection_state_cancelled: {
                PDebug(@"Event: nw_connection_state_cancelled");
                break;
            }
            default: {
                PError(@"Unknown nw_connection_state: %u", state);
                break;
            }
        }
    });
    nw_connection_start(connection);
}

- (void) getHeadersForConnection:(nw_connection_t)connection queue:(dispatch_queue_t)queue completed:(void (^)(CKHTTPResponse *))completed {
    NSData * requestData = [CKHTTPClient requestForHost:self.parameters.hostAddress];
    dispatch_data_t data = dispatch_data_create(requestData.bytes, requestData.length, dispatch_get_main_queue(), DISPATCH_DATA_DESTRUCTOR_DEFAULT);

    [CKHTTPClient responseFromNetworkConnection:connection completed:^(CKHTTPResponse * response) {
        completed(response);
    }];

    nw_connection_send(connection, data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, false, ^(nw_error_t error) {
        if (error != nil) {
            PError(@"Error writing HTTP request: %@", error.description);
        }
    });
}

- (CKRevoked *) getRevokedInformationForCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer {
    CKOCSPResponse * ocspResponse;
    CKCRLResponse * crlResponse;

    if (self.parameters.checkOCSP) {
        NSError * err = [[CKOCSPManager sharedManager] queryCertificate:certificate issuer:issuer response:&ocspResponse];
        if (err != nil) {
            PError(@"OCSP Error: %@", err.description);
        }
    }
    if (self.parameters.checkCRL) {
        NSError * err = [[CKCRLManager sharedManager] queryCertificate:certificate issuer:issuer response:&crlResponse];
        if (err != nil) {
            PError(@"CRL Error: %@", err.description);
        }
    }
    return [CKRevoked fromOCSPResponse:ocspResponse andCRLResponse:crlResponse];
}

@end
