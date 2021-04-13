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

@end
