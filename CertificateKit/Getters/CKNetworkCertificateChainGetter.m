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

@interface CKNetworkCertificateChainGetter ()

@end

@implementation CKNetworkCertificateChainGetter

- (void) performTaskForURL:(NSURL *)url {
    // TODO: Figure out if we can not have this entire thing be wrapped in an availability block

    /**
     Things the getter needs to be able to get:
     1. all of the certificates (obviously)
     2. trust status
     3. ciphersuite
     4. protocol version
     5. remote address
     */
    if (@available(iOS 13, *)) { // TODO: Change this to 12
        const char * host = url.host.UTF8String;
        unsigned int port = url.port != nil ? [url.port unsignedIntValue] : 443;
        const char * portStr = [[NSString alloc] initWithFormat:@"%i", port].UTF8String;
        nw_endpoint_t endpoint = nw_endpoint_create_host(host, portStr);

        dispatch_queue_t nw_dispatch_queue = dispatch_queue_create("com.tlsinspector.CertificateKit.NWGetter", NULL);

        nw_parameters_configure_protocol_block_t configure_tls = ^(nw_protocol_options_t tls_options) {
            sec_protocol_options_t sec_options = nw_tls_copy_sec_protocol_options(tls_options);
            sec_protocol_options_add_tls_ciphersuite(sec_options, (SSLCipherSuite)TLS_CHACHA20_POLY1305_SHA256);
            sec_protocol_options_set_verify_block(sec_options, ^(sec_protocol_metadata_t  _Nonnull metadata, sec_trust_t  _Nonnull trust_ref, sec_protocol_verify_complete_t  _Nonnull complete) {
                const char * server_name = sec_protocol_metadata_get_server_name(metadata);

                // TODO: these are iOS 13+ - also support the deprecated methods for iOS 12
                tls_protocol_version_t proto_v = sec_protocol_metadata_get_negotiated_tls_protocol_version(metadata);
                tls_ciphersuite_t suite = sec_protocol_metadata_get_negotiated_tls_ciphersuite(metadata);
                NSLog(@"Server name: %s, protocol version: %hu, suite: %hu", server_name, proto_v, suite);
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

            if (state == nw_connection_state_waiting) {
                // … tell the user that a connection couldn’t be opened but will retry when conditions are favourable …
            } else if (state == nw_connection_state_failed) {
                // … tell the user that the connection has failed irrecoverably …
            } else if (state == nw_connection_state_ready) {
                nw_connection_cancel(connection);
                // … tell the user that you are connected …
            } else if (state == nw_connection_state_cancelled) {
                // Do we release on iOS?
            }
        });
        nw_connection_start(connection);
    }
}

@end
