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

    NSRegularExpression * protocolPattern = [NSRegularExpression regularExpressionWithPattern:@"^[a-z]+://" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression * portPattern = [NSRegularExpression regularExpressionWithPattern:@":[0-9]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSMutableString * hostAddress = [NSMutableString stringWithString:parameters.hostAddress];
    [protocolPattern replaceMatchesInString:hostAddress options:0 range:NSMakeRange(0, [parameters.hostAddress length]) withTemplate:@""];
    getParams.hostAddress = hostAddress;

    // Look for a port suffix
    NSArray<NSTextCheckingResult *> * portMatches = [portPattern matchesInString:hostAddress options:0 range:NSMakeRange(0, hostAddress.length)];
    if (portMatches.count == 1) {
        NSString * portString = [[hostAddress substringWithRange:portMatches[0].range] substringFromIndex:1];
        [hostAddress replaceCharactersInRange:portMatches[0].range withString:@""];
        getParams.port = [portString intValue];

        // IPv6 addresses may be wrapped in brackets when a port is included
        if ([hostAddress characterAtIndex:0] == 91 && [hostAddress characterAtIndex:hostAddress.length-1] == 93) {
            [hostAddress replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [hostAddress replaceCharactersInRange:NSMakeRange(hostAddress.length-1, 1) withString:@""];
        }
    }

    if (getParams.port == 0) {
        getParams.port = 443;
    }

    return getParams;
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
