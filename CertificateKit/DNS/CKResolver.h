//
//  CKResolver.h
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

@interface CKResolver : NSObject

+ (CKResolver * _Nonnull) sharedResolver;
- (CKResolvedAddress * _Nullable) getAddressFromDomain:(NSString * _Nonnull)domain withError:(NSError * _Nullable *)error;
- (CKResolvedAddress * _Nullable) getIPv4AddressFromDomain:(NSString * _Nonnull)domain withError:(NSError * _Nullable *)error;
- (CKResolvedAddress * _Nullable) getIPv6AddressFromDomain:(NSString * _Nonnull)domain withError:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
