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

- (CKResolvedAddress *) getAddressFromDomain:(NSString *)domain withAddressFamily:(int)aiFamily withError:(NSError **)error {
    int err;
    struct addrinfo hints;
    struct addrinfo *result;
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = aiFamily;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_flags = 0;
    hints.ai_protocol = 0;
    const char * query = [domain UTF8String];
    PDebug(@"Resolving domain: query='%s' address_family='%i'", query, aiFamily);
    err = getaddrinfo(query, NULL, &hints, &result);
    if (err != 0) {
        if (error != nil)
            *error = [[NSError alloc] initWithDomain:@"com.tlsinspector.CKResolver" code:err userInfo:@{NSLocalizedDescriptionKey: [self gaiErrorMessage:err]}];
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
    } else {
        if (error != nil)
            *error = [[NSError alloc] initWithDomain:@"com.tlsinspector.CKResolver" code:err userInfo:@{NSLocalizedDescriptionKey: @"Unknown address family"}];
        return nil;
    }

    CKResolvedAddress * resolvedAddress = [CKResolvedAddress new];
    resolvedAddress.address = address;
    resolvedAddress.query = domain;
    if (result->ai_family == AF_INET) {
        resolvedAddress.version = CKIPAddressVersion4;
    } else if (result->ai_family == AF_INET6) {
        resolvedAddress.version = CKIPAddressVersion6;
    }

    free(result);

    return resolvedAddress;
}

- (CKResolvedAddress *) getAddressFromDomain:(NSString *)domain withError:(NSError **)error {
    return [self getAddressFromDomain:domain withAddressFamily:AF_UNSPEC withError:error];
}

- (CKResolvedAddress *) getIPv4AddressFromDomain:(NSString *)domain withError:(NSError **)error {
    return [self getAddressFromDomain:domain withAddressFamily:AF_INET withError:error];
}

- (CKResolvedAddress *) getIPv6AddressFromDomain:(NSString *)domain withError:(NSError * _Nullable __autoreleasing *)error {
    return [self getAddressFromDomain:domain withAddressFamily:AF_INET6 withError:error];
}

- (NSString *) gaiErrorMessage:(int)code {
    switch (code) {
    case EAI_ADDRFAMILY:
        return @"Address family for hostname not supported (EAI::ADDRFAMILY)";
    case EAI_AGAIN:
        return @"Temporary failure in name resolution (EAI::AGAIN)";
    case EAI_BADFLAGS:
        return @"EAI::BADFLAGS";
    case EAI_FAIL:
        return @"Non-recoverable failure in name resolution (EAI::FAIL)";
    case EAI_FAMILY:
        return @"EAI::FAMILY";
    case EAI_MEMORY:
        return @"EAI::MEMORY";
    case EAI_NODATA:
        return @"No address associated with hostname (EAI::NODATA)";
    case EAI_NONAME:
        return @"Hostname nor servname provided, or not known (EAI::NONAME)";
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
