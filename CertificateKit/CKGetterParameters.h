//
//  CKGetterParameters.h
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
#import "CKResolvedAddress.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Backend parameters that are sutible for the getters. This should be derived from the user-specified inspect parameters.
 */
@interface CKGetterParameters : NSObject

@property (strong, nonatomic, nonnull) NSString * hostAddress;
@property (nonatomic) UInt16 port;
@property (strong, nonatomic, nullable) NSString * ipAddress;
@property (strong, nonatomic, nullable) CKResolvedAddress * resolvedAddress;
@property (nonatomic) BOOL queryServerInfo;
@property (nonatomic) BOOL checkOCSP;
@property (nonatomic) BOOL checkCRL;
@property (nonatomic) CRYPTO_ENGINE cryptoEngine;
@property (nonatomic) IP_VERSION ipVersion;
@property (strong, nonatomic, nullable) NSString * ciphers;
+ (CKGetterParameters * _Nonnull) fromInspectParameters:(CKInspectParameters * _Nonnull)parameters;
@property (strong, nonatomic, nonnull, readonly) NSString * socketAddress;

@end

NS_ASSUME_NONNULL_END
