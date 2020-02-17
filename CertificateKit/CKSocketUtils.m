//
//  CKSocketUtils.m
//
//  MIT License
//
//  Copyright (c) 2020 Ian Spence
//  https://github.com/certificate-helper/CertificateKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
