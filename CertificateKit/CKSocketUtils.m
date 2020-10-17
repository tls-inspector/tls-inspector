//
//  CKSocketUtils.m
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

#import "CKSocketUtils.h"
#include <arpa/inet.h>

@implementation CKSocketUtils

+ (NSString *) remoteAddressForSocket:(int)socket {
    struct sockaddr_storage addr;
    socklen_t addr_len = sizeof(addr);
    if (getpeername(socket, (struct sockaddr *)&addr, &addr_len) != 0) {
        PError(@"Error getting peer name from socket (getpeername %s)", strerror(errno));
        return nil;
    }

    NSString * remoteAddressString;
    if (addr.ss_family == AF_INET) {
        char addressString[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &((struct sockaddr_in *)&addr)->sin_addr, addressString, INET_ADDRSTRLEN);
        remoteAddressString = [[NSString alloc] initWithUTF8String:addressString];
    } else if (addr.ss_family == AF_INET6) {
        char addressString[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &((struct sockaddr_in6 *)&addr)->sin6_addr, addressString, INET6_ADDRSTRLEN);
        remoteAddressString = [[NSString alloc] initWithUTF8String:addressString];
    } else {
        PError(@"Unknown address family from socket (%i)", addr.ss_family);
        return nil;
    }

    return remoteAddressString;
}
@end
