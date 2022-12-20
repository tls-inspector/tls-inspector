//
//  CKCertificateBundleMetadata.h
//
//  LGPLv3
//
//  Copyright (c) 2022 Ian Spence
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

@interface CKCertificateBundleMetadata : NSObject

/// The date when the bundle was created
@property (strong, nonatomic, readonly, nullable) NSDate * bundleDate;

/// The SHA256 sum of the bundle file
@property (strong, nonatomic, readonly, nullable) NSString * bundleSHA256;

/// The number of certificates in the bundle
@property (strong, nonatomic, readonly, nullable) NSNumber * certificateCount;

/// Create a new metadata object from the given dictionary
/// - Parameter dictionary: dictionary containing metadata
+ (CKCertificateBundleMetadata * _Nullable) metadataFrom:(NSDictionary<NSString *, id> * _Nonnull)dictionary;

/// Create a new bundle metadata object
/// - Parameters:
///   - date: bundle date
///   - bundleSHA256: bundle SHA256 sum
///   - certificateCount: number of certificates
- (CKCertificateBundleMetadata * _Nonnull) initWithDate:(NSDate * _Nonnull)date bundleSHA256:(NSString * _Nonnull)bundleSHA256 certificateCount:(NSNumber * _Nonnull)certificateCount;

@end

NS_ASSUME_NONNULL_END
