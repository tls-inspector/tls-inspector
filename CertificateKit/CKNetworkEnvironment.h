//
//  CKNetworkEnvironment.h
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

#import <Foundation/Foundation.h>
#import "CKIPAddress.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Utilities for evalulating the network environment of the current device
 */
@interface CKNetworkEnvironment : NSObject

/**
 Determine which IP version should be used when connecting to the given host, accounting for IPv4 only, IPv6 only, and dual-stack networks. If host is an IP address, use 'example.com'.
 Returns either CKIPVersion 4 or 6. If unable to determine (due to no connection) will return CKIPVersionAutomatic and populate error. Address will be populated with either the IPv4 or IPv6 resolved address for the host.

 This method will block for no more than 3 seconds.
 */
+ (CKIPVersion) getPreferredIPVersionOfHost:(NSString * _Nonnull)host address:(NSString * _Nullable * _Nonnull)address error:(NSError * _Nullable * _Nonnull)error;

/**
 Return a dictionary mapping an interface name to an array of IP addresses for that interface
 */
+ (NSDictionary<NSString *, NSArray<CKIPAddress *> *> * _Nullable) getInterfaceAddresses;

/**
 Is IPv6 available on this device. This is determined to be true if one of the outbound interface has a routable (non-loopback and non-link-local) IPv6 address.
 */
+ (BOOL) ipv6IsAvailable;

/**
 Is an HTTP proxy configured on this device
 */
+ (BOOL) httpProxyConfigured;

@end

NS_ASSUME_NONNULL_END
