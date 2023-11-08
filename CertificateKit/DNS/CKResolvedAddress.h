//
//  CKResolvedAddress.h
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

#import <Foundation/Foundation.h>
#import <CertificateKit/CKTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKResolvedAddress : NSObject

/**
 The original query that was sent to the resolver.
 */
@property (strong, nonatomic, nonnull) NSString * query;

/**
 The result address (IPv4 or IPv6) that the query resolved to.
 */
@property (strong, nonatomic, nonnull) NSString * address;

/**
 The IP version for the resolved address.
 */
@property (nonatomic) CKIPVersion version;

@end

NS_ASSUME_NONNULL_END
