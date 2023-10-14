//
//  CKNetworkEnvironment.m
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

#import "CKNetworkEnvironment.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <mach/mach_time.h>

@implementation CKNetworkEnvironment

+ (CKIPVersion) getPreferredIPVersionOfHost:(NSString *)host address:(NSString **)address error:(NSError **)error {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();

    NSString __block * ipv4Address = nil;
    NSNumber __block * ipv4Success = @NO;
    NSNumber __block * ipv4Failed = @NO;
    NSNumber __block * ipv4Elapsed;
    NSString __block * ipv6Address = nil;
    NSNumber __block * ipv6Success = @NO;
    NSNumber __block * ipv6Failed = @NO;
    NSNumber __block * ipv6Elapsed;

    dispatch_group_async(group, queue, ^{
        uint64_t startTime = mach_absolute_time();

        int err;
        struct addrinfo hints;
        struct addrinfo *result;
        memset(&hints, 0, sizeof(struct addrinfo));
        hints.ai_family = AF_INET;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = 0;
        hints.ai_protocol = 0;
        const char * query = "example.com";
        err = getaddrinfo(query, "80", &hints, &result);
        if (err != 0) {
            ipv4Failed = @YES;
            NSLog(@"IPv4 failed %s", strerror(errno));
            return;
        }

        if (result->ai_family != AF_INET) {
            ipv4Failed = @YES;
            NSLog(@"IPv4 failed %s", strerror(errno));
            return;
        }

        char addressString[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &((struct sockaddr_in *)result->ai_addr)->sin_addr, addressString, INET_ADDRSTRLEN);
        ipv6Address = [NSString stringWithUTF8String:addressString];

        int sockfd = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
        int conSuccess = connect(sockfd, result->ai_addr, result->ai_addrlen);
        close(sockfd);
        if (conSuccess != 0) {
            ipv4Failed = @YES;
            NSLog(@"IPv4 failed %s", strerror(errno));
            return;
        }
        uint64_t endTime = mach_absolute_time();
        uint64_t elapsedTime = endTime - startTime;
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        double elapsedTimeInNanoseconds = elapsedTime * ((double)timebase.numer / timebase.denom);
        ipv4Success = @YES;
        ipv4Elapsed = [NSNumber numberWithDouble:elapsedTimeInNanoseconds];
        NSLog(@"IPv4 passed");
    });

    dispatch_group_async(group, queue, ^{
        uint64_t startTime = mach_absolute_time();

        int err;
        struct addrinfo hints;
        struct addrinfo *result;
        memset(&hints, 0, sizeof(struct addrinfo));
        hints.ai_family = AF_INET6;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = 0;
        hints.ai_protocol = 0;
        const char * query = "example.com";
        err = getaddrinfo(query, "http", &hints, &result);
        if (err != 0) {
            ipv6Failed = @YES;
            NSLog(@"IPv6 failed %s", strerror(errno));
            return;
        }

        if (result->ai_family != AF_INET6) {
            ipv6Failed = @YES;
            NSLog(@"IPv6 failed %s", strerror(errno));
            return;
        }

        char addressString[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &((struct sockaddr_in6 *)result->ai_addr)->sin6_addr, addressString, INET6_ADDRSTRLEN);
        ipv6Address = [NSString stringWithUTF8String:addressString];

        int sockfd = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
        int conSuccess = connect(sockfd, result->ai_addr, result->ai_addrlen);
        close(sockfd);
        if (conSuccess != 0) {
            ipv6Failed = @YES;
            NSLog(@"IPv6 failed %s", strerror(errno));
            return;
        }

        uint64_t endTime = mach_absolute_time();
        uint64_t elapsedTime = endTime - startTime;
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        double elapsedTimeInNanoseconds = elapsedTime * ((double)timebase.numer / timebase.denom);
        ipv6Success = @YES;
        ipv6Elapsed = [NSNumber numberWithDouble:elapsedTimeInNanoseconds];
        NSLog(@"IPv6 passed");
    });

    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));

    /// If both IPv4 and IPv6 were available: calculate the difference in elapsed time. If the difference is less than 1ms; prefer IPv6, otherwise pick the faster of the two.
    /// If only one version is available, pick that version.
    /// If no versions were available, then - shockingly - we return an error. Who could have perdicted this outcome?
    if (ipv4Success.boolValue && ipv6Success.boolValue) {
        double differenceNS = fabs(ipv4Elapsed.doubleValue - ipv6Elapsed.doubleValue);
        if (differenceNS < 1000000 || ipv4Elapsed.doubleValue > ipv6Elapsed.doubleValue) {
            *address = ipv6Address;
            return CKIPVersionIPv6;
        }

        *address = ipv4Address;
        return CKIPVersionIPv4;
    } else if (ipv6Success.boolValue) {
        *address = ipv6Address;
        return CKIPVersionIPv6;
    } else if (ipv4Success.boolValue) {
        *address = ipv4Address;
        return CKIPVersionIPv4;
    }

    *error = MAKE_ERROR(1, @"No network connection");
    return CKIPVersionAutomatic;
}

+ (NSDictionary<NSString *, NSArray<NSString *> *> *) getInterfaceAddresses {
    NSMutableDictionary * addresses = [NSMutableDictionary new];

    struct ifaddrs *ifa, *ifa_tmp;
    char addr[INET6_ADDRSTRLEN];

    if (getifaddrs(&ifa) == -1) {
        return nil;
    }

    ifa_tmp = ifa;
    while (ifa_tmp) {
        if ((ifa_tmp->ifa_addr) && ((ifa_tmp->ifa_addr->sa_family == AF_INET) ||
                                  (ifa_tmp->ifa_addr->sa_family == AF_INET6))) {
            NSString * interfaceName = [[NSString alloc] initWithUTF8String:ifa_tmp->ifa_name];
            NSString * address;

            if (ifa_tmp->ifa_addr->sa_family == AF_INET) {
                // create IPv4 string
                struct sockaddr_in *in = (struct sockaddr_in*) ifa_tmp->ifa_addr;
                inet_ntop(AF_INET, &in->sin_addr, addr, sizeof(addr));
                address = [[NSString alloc] initWithUTF8String:addr];

                // Skip loopback addresses
                if ([address hasPrefix:@"127."]) {
                    ifa_tmp = ifa_tmp->ifa_next;
                    continue;
                }
            } else { // AF_INET6
                // create IPv6 string
                struct sockaddr_in6 *in6 = (struct sockaddr_in6*) ifa_tmp->ifa_addr;
                inet_ntop(AF_INET6, &in6->sin6_addr, addr, sizeof(addr));
                address = [[NSString alloc] initWithUTF8String:addr];

                // Skip loopback addresses
                if ([address isEqualToString:@"::1"]) {
                    ifa_tmp = ifa_tmp->ifa_next;
                    continue;
                }
                // Skip ll addresses
                if ([address hasPrefix:@"fe80:"]) {
                    ifa_tmp = ifa_tmp->ifa_next;
                    continue;
                }
            }

            if ([addresses valueForKey:interfaceName] == nil) {
                [addresses setValue:@[[CKIPAddress fromString:address]] forKey:interfaceName];
            } else {
                NSMutableArray * ifaddrs = [addresses[interfaceName] mutableCopy];
                [ifaddrs addObject:[CKIPAddress fromString:address]];
                [addresses setValue:ifaddrs forKey:interfaceName];
            }
        }
        ifa_tmp = ifa_tmp->ifa_next;
    }
    freeifaddrs(ifa);

    return addresses;
}

+ (BOOL) ipv6IsAvailable {
    NSDictionary<NSString *, NSArray<CKIPAddress *> *> * addresses = [CKNetworkEnvironment getInterfaceAddresses];

    for (NSString * interfaceName in addresses.allKeys) {
        NSArray<CKIPAddress *> * interfaceAddresses = addresses[interfaceName];
        for (CKIPAddress * address in interfaceAddresses) {
            if (address.version == CKIPVersionIPv6) {
                return true;
            }
        }
    }

    return false;
}

+ (BOOL) httpProxyConfigured {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFString = (const CFStringRef)CFDictionaryGetValue(proxySettings, (const void*)kCFNetworkProxiesHTTPProxy);
    NSString * proxyString = (__bridge NSString *)(proxyCFString);
    BOOL usingProxy = proxyString != nil && proxyString.length > 0;

    CFRelease(proxySettings);
    return usingProxy;
}

@end
