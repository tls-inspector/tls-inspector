//
//  CKDNSClient.h
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
#import <CertificateKit/CKDNSRecordType.h>
#import <CertificateKit/CKDNSResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 DNS over HTTPS client
 */
@interface CKDNSClient : NSObject

/**
 Shared instance of the DNS over HTTPS client. Always use this rather than creating your own instance.
 */
+ (CKDNSClient * _Nonnull) sharedClient;

/**
 Performs a DNS query against the target server for a specific record type of the host
 */
- (void) resolve:(NSString * _Nonnull)host ofAddressVersion:(CKIPVersion)addressVersion onServer:(NSString * _Nonnull)server completed:(void (^_Nonnull)(CKDNSResult * _Nullable, NSError * _Nullable))completed;

/**
 Try to determine the preferred record type for the given network environment
 */
- (CKDNSRecordType) getPreferredRecordTypeWithError:(NSError * _Nonnull * _Nullable)error;

#if DEBUG
- (void) DANGEROUS_DISABLE_SSL_VERIFY;
#endif

@end

NS_ASSUME_NONNULL_END
