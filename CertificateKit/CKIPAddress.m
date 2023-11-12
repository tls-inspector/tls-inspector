//
//  CKIPAddress.m
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

#import <CertificateKit/CKIPAddress.h>
#import <arpa/inet.h>
@import Network;

@implementation CKIPAddress

+ (CKIPAddress *) fromString:(NSString *)value {
    CKIPAddress * address = [CKIPAddress new];

    if ([value.lowercaseString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":abcdef"]].location == NSNotFound) {
        address.version = CKIPVersionIPv4;

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
        address.version = CKIPVersionIPv6;

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

+ (CKIPAddress *) addressFromSockaddr:(struct sockaddr_storage *)addr {
    NSString * remoteAddressString;
    if (addr->ss_family == AF_INET) {
        char addressString[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &((struct sockaddr_in *)addr)->sin_addr, addressString, INET_ADDRSTRLEN);
        remoteAddressString = [[NSString alloc] initWithUTF8String:addressString];
    } else if (addr->ss_family == AF_INET6) {
        if (IN6_IS_ADDR_V4MAPPED(&((struct sockaddr_in6 *)addr)->sin6_addr)) {
            struct sockaddr_in v4_addr;
            memcpy(&v4_addr.sin_addr, ((char*) &((struct sockaddr_in6 *)addr)->sin6_addr) + 12, 4);
            v4_addr.sin_family = AF_INET;
            memcpy((struct sockaddr_in6 *)addr, &v4_addr, sizeof(v4_addr));

            char address4String[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &v4_addr.sin_addr, address4String, INET_ADDRSTRLEN);
            remoteAddressString = [[NSString alloc] initWithUTF8String:address4String];
        } else {
            char addressString[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, &((struct sockaddr_in6 *)addr)->sin6_addr, addressString, INET6_ADDRSTRLEN);
            remoteAddressString = [[NSString alloc] initWithUTF8String:addressString];
        }
    } else {
        PError(@"Unknown address family from socket (%i)", addr->ss_family);
        return nil;
    }

    return [CKIPAddress fromString:remoteAddressString];
}

+ (CKIPAddress *) remoteAddressForSocket:(int)socket {
    struct sockaddr_storage addr;
    socklen_t addr_len = sizeof(addr);
    if (getpeername(socket, (struct sockaddr *)&addr, &addr_len) != 0) {
        PError(@"Error getting peer name from socket (getpeername %s)", strerror(errno));
        return nil;
    }

    return [CKIPAddress addressFromSockaddr:&addr];
}

+ (CKIPAddress * _Nullable) remoteAddressFromEndpoint:(nw_endpoint_t)endpoint {
    struct sockaddr_storage * addr = (struct sockaddr_storage *)nw_endpoint_get_address(endpoint);

    return [CKIPAddress addressFromSockaddr:addr];
}


- (NSString *) description {
    return self.full;
}

@end
