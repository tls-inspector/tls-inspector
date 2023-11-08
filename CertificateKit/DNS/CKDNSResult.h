//
//  CKDNSResult.h
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
#import <CertificateKit/CKDNSResource.h>
#import <CertificateKit/CKDNSResponseCode.h>

NS_ASSUME_NONNULL_BEGIN

/// Describes the result of a DNS request
@interface CKDNSResult : NSObject

@property (nonatomic) CKDNSResponseCode responseCode;

@property (strong, nonatomic, nullable) NSArray<CKDNSResource *> * resources;

/// Return a list of addresses for the given name. The trailing '.' is optional for name.
- (NSArray<NSString *> * _Nullable) addressesForName:(NSString * _Nonnull)name error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
