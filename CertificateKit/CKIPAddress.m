//
//  CKInspectResponse.m
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

#import "CKIPAddress.h"
#import <arpa/inet.h>

@implementation CKIPAddress

+ (CKIPAddress *) fromString:(NSString *)value {
    CKIPAddress * address = [CKIPAddress new];

    if ([value.lowercaseString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":abcdef"]].location == NSNotFound) {
        address.version = CKIPAddressVersion4;

        in_addr_t addr = inet_addr(value.UTF8String);
        (void)addr;

        struct in_addr result;
        if (inet_pton(AF_INET, value.UTF8String, &result) != 1) {
            PError(@"Invalid IP address: '%@'", value);
            return nil;
        }
        char str[INET_ADDRSTRLEN];
        if (inet_ntop(AF_INET, &result, str, INET_ADDRSTRLEN) == NULL) {
            PError(@"Invalid IP address: '%@'", value);
            return nil;
        }
        address.address = [[NSString alloc] initWithUTF8String:str];
        address.full = [[NSString alloc] initWithUTF8String:str];
    } else {
        address.version = CKIPAddressVersion6;

        struct in6_addr result;
        if (inet_pton(AF_INET6, value.UTF8String, &result) != 1) {
            PError(@"Invalid IP address: '%@'", value);
            return nil;
        }
        char fullStr[INET6_ADDRSTRLEN];
        // Expand the full IPv6 address instead of using inet_ntop, which can return a shortened address
        sprintf(fullStr, "%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x",
                (int)result.s6_addr[0], (int)result.s6_addr[1],
                (int)result.s6_addr[2], (int)result.s6_addr[3],
                (int)result.s6_addr[4], (int)result.s6_addr[5],
                (int)result.s6_addr[6], (int)result.s6_addr[7],
                (int)result.s6_addr[8], (int)result.s6_addr[9],
                (int)result.s6_addr[10], (int)result.s6_addr[11],
                (int)result.s6_addr[12], (int)result.s6_addr[13],
                (int)result.s6_addr[14], (int)result.s6_addr[15]);
        address.full = [[NSString alloc] initWithUTF8String:fullStr];

        char str[INET_ADDRSTRLEN];
        if (inet_ntop(AF_INET6, &result, str, INET6_ADDRSTRLEN) == NULL) {
            PError(@"Invalid IP address: '%@'", value);
            return nil;
        }
        address.address = [[NSString alloc] initWithUTF8String:str];
    }

    return address;
}

- (NSString *) description {
    return self.full;
}

@end
