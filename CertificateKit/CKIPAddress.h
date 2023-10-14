//
//  CKIPAddress.h
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

NS_ASSUME_NONNULL_BEGIN

/// Describes an IP address
@interface CKIPAddress : NSObject

/// Create a new CKIPAddress object from the given IP address string
/// - Parameter value: A string representing an IP address, either IPv4 or 6. IPv4 addresses must have all 4 quartets, however leading redundant zeros may be omitted. IPv6 addresses may be shortened.
+ (CKIPAddress * _Nullable) fromString:(NSString * _Nonnull)value;

/// The address version of family
@property (nonatomic) CKIPVersion version;

/// The normal IP address, may be shortened.
@property (strong, nonatomic, nonnull) NSString * address;

/// The full IP address. For IPv6 addresses this expands the entire value of the sextets and populates zero values.
@property (strong, nonatomic, nonnull) NSString * full;

- (NSString * _Nonnull) description;

@end

NS_ASSUME_NONNULL_END
