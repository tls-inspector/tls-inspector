//
//  CKResolver.m
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

#import "CKResolver.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>

@implementation CKResolver

static id _instance;

+ (CKResolver *) sharedResolver {
    if (!_instance) {
        _instance = [CKResolver new];
    }
    return _instance;
}

- (id) init {
    if (_instance == nil) {
        _instance = [super init];
    }
    return _instance;
}

- (NSString *) getAddressFromDomain:(NSString *)domain withAddressFamily:(int)aiFamily withError:(NSError **)error {
    int err;
    struct addrinfo hints;
    struct addrinfo *result;
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = aiFamily;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_flags = 0;
    hints.ai_protocol = 0;
    PDebug(@"Resolving domain: domain='%@' address_family='%i'", domain, aiFamily);
    err = getaddrinfo(domain.UTF8String, NULL, &hints, &result);
    if (err != 0) {
        if (error != NULL) {
            NSError * connectError = [[NSError alloc] initWithDomain:@"com.tlsinspector.CKResolver" code:err userInfo:@{NSLocalizedDescriptionKey: [self gaiErrorMessage:err]}];
            *error = connectError;
        }
        return nil;
    }

    NSString * address;
    if (result->ai_family == AF_INET) {
        char addressString[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &((struct sockaddr_in *)result->ai_addr)->sin_addr, addressString, INET_ADDRSTRLEN);
        address = [[NSString alloc] initWithUTF8String:addressString];
    } else if (result->ai_family == AF_INET6) {
        char addressString[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &((struct sockaddr_in6 *)result->ai_addr)->sin6_addr, addressString, INET6_ADDRSTRLEN);
        address = [[NSString alloc] initWithUTF8String:addressString];
    }
    free(result);

    return address;
}

- (NSString *) getAddressFromDomain:(NSString *)domain withError:(NSError **)error {
    return [self getAddressFromDomain:domain withAddressFamily:AF_UNSPEC withError:error];
}

- (NSString *) getIPv4AddressFromDomain:(NSString *)domain withError:(NSError **)error {
    return [self getAddressFromDomain:domain withAddressFamily:AF_INET withError:error];
}

- (NSString *) getIPv6AddressFromDomain:(NSString *)domain withError:(NSError * _Nullable __autoreleasing *)error {
    return [self getAddressFromDomain:domain withAddressFamily:AF_INET6 withError:error];
}

- (NSString *) gaiErrorMessage:(int)code {
    switch (code) {
    case EAI_ADDRFAMILY:
        return @"EAI::ADDRFAMILY";
    case EAI_AGAIN:
        return @"EAI::AGAIN";
    case EAI_BADFLAGS:
        return @"EAI::BADFLAGS";
    case EAI_FAIL:
        return @"EAI::FAIL";
    case EAI_FAMILY:
        return @"EAI::FAMILY";
    case EAI_MEMORY:
        return @"EAI::MEMORY";
    case EAI_NODATA:
        return @"EAI::NODATA";
    case EAI_NONAME:
        return @"EAI::NONAME";
    case EAI_SERVICE:
        return @"EAI::SERVICE";
    case EAI_SOCKTYPE:
        return @"EAI::SOCKTYPE";
    case EAI_SYSTEM:
        return @"EAI::SYSTEM";
    default:
        return @"EAI::UNKNOWN";
    }
}

@end
