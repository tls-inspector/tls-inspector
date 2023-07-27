//
//  CKInspectParameters.m
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

#import "CKInspectParameters.h"
#import "CKResolvedAddress.h"
#import "CKRegex.h"
#import <arpa/inet.h>

@interface CKInspectParameters ()

@property (strong, nonatomic, nullable) CKResolvedAddress * resolvedAddress;
@property (strong, nonatomic, nullable) NSString * socketAddress;

@end

@implementation CKInspectParameters

#define KEY_HOST_ADDRESS @"host_address"
#define KEY_PORT @"port"
#define KEY_IP_ADDRESS @"ip_address"
#define KEY_QUERY_SERVER_INFO @"query_server_info"
#define KEY_CHECK_OCSP @"check_ocsp"
#define KEY_CHECK_CRL @"check_crl"
#define KEY_CRYPTO_ENGINE @"crypto_engine"
#define KEY_IP_VERSION @"ip_version"
#define KEY_CIPHERS @"ciphers"

+ (CKInspectParameters *) fromQuery:(NSString *)query {
    CKInspectParameters * parameters = [CKInspectParameters new];

    CKRegex * protocolPattern = [CKRegex compile:@"^[a-z]+://"];
    CKRegex * wrappedIPv6AddressPattern = [CKRegex compile:@"\\[[0-9a-f\\:]+\\]"];

    // Strip any protocol prefix
    NSString * hostAddress = [[protocolPattern replaceAllMatchesIn:query with:@""] lowercaseString];

    // Remove any path components (if present)
    if ([hostAddress containsString:@"/"]) {
        hostAddress = [hostAddress componentsSeparatedByString:@"/"][0];
    }

    // Valid IP addresses can't contain a port, so no need to try and find and strip it
    if (![CKInspectParameters isValidIPAddress:hostAddress]) {
        // Catch IPv6 addresses that are wrapped in [] and contain a port
        if ([wrappedIPv6AddressPattern matches:hostAddress]) {
            // Get the address out of the brackets
            NSString * wrappedAddress = [wrappedIPv6AddressPattern firstMatch:hostAddress];
            parameters.port = [CKInspectParameters getAndStripPortFrom:&hostAddress];
            // hostAddress gets updated by getAndStripPortFrom, repalce it with the value from wrappedAddress
            hostAddress = [[wrappedAddress substringFromIndex:1] substringToIndex:wrappedAddress.length-2];
        } else {
            // Not a valid IP address and not a wrapped IPv6 address
            UInt16 port = [CKInspectParameters getAndStripPortFrom:&hostAddress];
            // Note: If the user specified a port in both the host address and in the port property then we
            // ignore the port in the host address and use the specified value.
            if (parameters.port == 0) {
                parameters.port = port;
            }
        }
    }

    parameters.hostAddress = hostAddress;
    if (parameters.port == 0) {
        parameters.port = 443;
    }

    return parameters;
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
    return ([CKInspectParameters isValidIPv4Address:hostAddress] || [CKInspectParameters isValidIPv6Address:hostAddress]);
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

- (BOOL) isEqual:(CKInspectParameters *)other {
    if (other == nil) {
        return NO;
    }

    BOOL hostAddressEquals = [self.hostAddress isEqualToString:other.hostAddress];
    BOOL portEquals = self.port == other.port;
    BOOL ipAddressEquals;
    if (self.ipAddress == nil && other.ipAddress == nil) {
        ipAddressEquals = YES;
    } else {
        ipAddressEquals = [self.ipAddress isEqualToString:other.ipAddress];
    }
    BOOL queryServerInfoEquals = self.queryServerInfo == other.queryServerInfo;
    BOOL checkOCSPEquals = self.checkOCSP == other.checkOCSP;
    BOOL checkCRLEquals = self.checkCRL == other.checkCRL;
    BOOL cryptoEngineEquals = self.cryptoEngine == other.cryptoEngine;
    BOOL ipVersionEquals = self.ipVersion == other.ipVersion;
    BOOL ciphersEquals = [self.ciphers isEqualToString:other.ciphers];

    return hostAddressEquals &&
        portEquals &&
        ipAddressEquals &&
        queryServerInfoEquals &&
        checkOCSPEquals &&
        checkCRLEquals &&
        cryptoEngineEquals &&
        ipVersionEquals &&
        ciphersEquals;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
        KEY_HOST_ADDRESS: self.hostAddress,
        KEY_PORT: [NSNumber numberWithUnsignedInt:self.port],
        KEY_IP_ADDRESS: self.ipAddress == nil ? @"" : self.ipAddress,
        KEY_QUERY_SERVER_INFO: [NSNumber numberWithBool:self.queryServerInfo],
        KEY_CHECK_OCSP: [NSNumber numberWithBool:self.checkOCSP],
        KEY_CHECK_CRL: [NSNumber numberWithBool:self.checkCRL],
        KEY_CRYPTO_ENGINE: [NSNumber numberWithInt:self.cryptoEngine],
        KEY_IP_VERSION: [NSNumber numberWithInt:self.ipVersion],
        KEY_CIPHERS: self.ciphers,
    };
}

+ (CKInspectParameters *) fromDictionary:(NSDictionary<NSString *, id> *)d {
    NSString * hostAddress = d[KEY_HOST_ADDRESS];
    NSNumber * portNumber = d[KEY_PORT];
    NSString * ipAddress = d[KEY_IP_ADDRESS];
    NSNumber * queryServerInfoNumber = d[KEY_QUERY_SERVER_INFO];
    NSNumber * checkOCSPNumber = d[KEY_CHECK_OCSP];
    NSNumber * checkCRLNumber = d[KEY_CHECK_CRL];
    NSNumber * cryptoEngineNumber = d[KEY_CRYPTO_ENGINE];
    NSNumber * ipVersionNumber = d[KEY_IP_VERSION];
    NSString * ciphers = d[KEY_CIPHERS];

    if (hostAddress == nil ||
        portNumber == nil ||
        ipAddress == nil ||
        queryServerInfoNumber == nil ||
        checkOCSPNumber == nil ||
        checkCRLNumber == nil ||
        cryptoEngineNumber == nil ||
        ipVersionNumber == nil ||
        ciphers == nil) {
        return nil;
    }

    CKInspectParameters * parameters = [CKInspectParameters new];
    parameters.hostAddress = hostAddress;
    parameters.port = portNumber.unsignedIntValue;
    parameters.ipAddress = ipAddress.length == 0 ? nil : ipAddress;
    parameters.queryServerInfo = queryServerInfoNumber.boolValue;
    parameters.checkOCSP = checkOCSPNumber.boolValue;
    parameters.checkCRL = checkCRLNumber.boolValue;
    parameters.cryptoEngine = (CRYPTO_ENGINE)cryptoEngineNumber.intValue;
    parameters.ipVersion = (IP_VERSION)ipVersionNumber.intValue;
    parameters.ciphers = ciphers;
    return parameters;
}

- (NSString *) cryptoEngineString {
    switch (self.cryptoEngine) {
        case CRYPTO_ENGINE_OPENSSL:
            return @"crypto_engine::openssl";
        case CRYPTO_ENGINE_NETWORK_FRAMEWORK:
            return @"crypto_engine::network_framework";
        case CRYPTO_ENGINE_SECURE_TRANSPORT:
            return @"crypto_engine::secure_transport";
    }

    return @"Unknown";
}

- (NSString *) ipVersionString {
    switch (self.ipVersion) {
        case IP_VERSION_AUTOMATIC:
            return @"Auto";
        case IP_VERSION_IPV4:
            return @"IPv4";
        case IP_VERSION_IPV6:
            return @"IPv6";
    }

    return @"Unknown";
}

- (CKInspectParameters *) copy {
    return [CKInspectParameters fromDictionary:[self dictionaryValue]];
}

@end
