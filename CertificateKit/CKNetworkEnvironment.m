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

@implementation CKNetworkEnvironment

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
