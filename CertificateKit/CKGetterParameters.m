//
//  CKGetterParameters.m
//
//  LGPLv3
//
//  Copyright (c) 2021 Ian Spence
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

#import "CKGetterParameters.h"
#import "CKRegex.h"
#include <arpa/inet.h>

@implementation CKGetterParameters

#define KEY_HOST_ADDRESS @"host_address"
#define KEY_PORT @"port"
#define KEY_IP_ADDRESS @"ip_address"
#define KEY_QUERY_SERVER_INFO @"query_server_info"
#define KEY_CHECK_OCSP @"check_ocsp"
#define KEY_CHECK_CRL @"check_crl"
#define KEY_CRYPTO_ENGINE @"crypto_engine"
#define KEY_IP_VERSION @"ip_version"
#define KEY_CIPHERS @"ciphers"

+ (CKGetterParameters *) fromInspectParameters:(CKInspectParameters *)parameters {
    CKGetterParameters * getParams = [CKGetterParameters new];
    getParams.hostAddress = [parameters.hostAddress copy];
    getParams.port = parameters.port + 0;
    getParams.ipAddress = [parameters.ipAddress copy];
    getParams.queryServerInfo = parameters.queryServerInfo;
    getParams.checkOCSP = parameters.checkOCSP;
    getParams.checkCRL = parameters.checkCRL;
    getParams.cryptoEngine = parameters.cryptoEngine;
    getParams.ipVersion = parameters.ipVersion;
    getParams.ciphers = [parameters.ciphers copy];

    CKRegex * protocolPattern = [CKRegex compile:@"^[a-z]+://"];
    CKRegex * wrappedIPv6AddressPattern = [CKRegex compile:@"\\[[0-9a-f\\:]+\\]"];

    // Strip any protocol prefix
    NSString * hostAddress = [protocolPattern replaceAllMatchesIn:parameters.hostAddress with:@""];

    // Remove any path components (if present)
    if ([hostAddress containsString:@"/"]) {
        hostAddress = [hostAddress componentsSeparatedByString:@"/"][0];
    }

    // Valid IP addresses can't contain a port, so no need to try and find and strip it
    if (![CKGetterParameters isValidIPAddress:hostAddress]) {
        // Catch IPv6 addresses that are wrapped in [] and contain a port
        if ([wrappedIPv6AddressPattern matches:hostAddress]) {
            // Get the address out of the brackets
            NSString * wrappedAddress = [wrappedIPv6AddressPattern firstMatch:hostAddress];
            getParams.port = [CKGetterParameters getAndStripPortFrom:&hostAddress];
            // hostAddress gets updated by getAndStripPortFrom, repalce it with the value from wrappedAddress
            hostAddress = [[wrappedAddress substringFromIndex:1] substringToIndex:wrappedAddress.length-2];
        } else {
            // Not a valid IP address and not a wrapped IPv6 address
            UInt16 port = [CKGetterParameters getAndStripPortFrom:&hostAddress];
            // Note: If the user specified a port in both the host address and in the port property then we
            // ignore the port in the host address and use the specified value.
            if (getParams.port == 0) {
                getParams.port = port;
            }
        }
    }

    getParams.hostAddress = hostAddress;
    if (getParams.port == 0) {
        getParams.port = 443;
    }

    return getParams;
}

+ (BOOL) isValidIPv4Address:(NSString *)hostAddress {
    unsigned char buf[sizeof(struct in_addr)];
    if (inet_pton(AF_INET, hostAddress.UTF8String, buf) != 0) {
        return YES;
    }
    return NO;
}

+ (BOOL) isValidIPv6Address:(NSString *)hostAddress {
    unsigned char buf[sizeof(struct in6_addr)];
    if (inet_pton(AF_INET6, hostAddress.UTF8String, buf) != 0) {
        return YES;
    }
    return NO;
}

+ (BOOL) isValidIPAddress:(NSString *)hostAddress {
    return ([CKGetterParameters isValidIPv4Address:hostAddress] || [CKGetterParameters isValidIPv6Address:hostAddress]);
}

/// Find a valid port suffix (e.g. :443) from hostAddress, remove it from hostAddress and return the port number
/// Will return either a valid port number or 0.
/// If no port suffix exists or the port number isn't valid it does nothing to hostAddress and returns 0.
+ (UInt16) getAndStripPortFrom:(NSString **)hostAddress {
    CKRegex * portPattern = [CKRegex compile:@":[0-9]+$"];

    NSString * portString = [portPattern firstMatch:*hostAddress];
    if (portString == nil) {
        return 0;
    }

    NSInteger rawPort = [[portString substringFromIndex:1] integerValue];
    if (rawPort < 0 || rawPort > 65535) {
        return 0;
    }

    *hostAddress = [*hostAddress substringToIndex:(*hostAddress).length-portString.length];
    return (UInt16)rawPort;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"hostAddress='%@' port=%i ipAddress='%@' queryServerInfo='%@' checkOCSP='%@' checkCRL='%@' cryptoEngine='%i' ipVersion='%i' ciphers='%@'",
            self.hostAddress.description,
            self.port,
            self.ipAddress.description,
            self.queryServerInfo ? @"YES" : @"NO",
            self.checkOCSP ? @"YES" : @"NO",
            self.checkCRL ? @"YES" : @"NO",
            self.cryptoEngine,
            self.ipVersion,
            self.ciphers.description];
}

- (NSString *) socketAddress {
    if (self.resolvedAddress.version == IP_VERSION_IPV6) {
        return [NSString stringWithFormat:@"[%@]:%i", self.ipAddress, self.port];
    }
    return [NSString stringWithFormat:@"%@:%i", self.ipAddress, self.port];
}

@end
