//
//  CKHTTPHeaders.h
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

@interface CKHTTPHeaders : NSObject

- (id) initWithData:(NSData *)data;

/// Return the first value for the given header name. Header names are case-insensitive and normalized to a lowercase string.
- (NSString * _Nullable) valueForHeader:(NSString * _Nonnull)headerName;

/// Return all values for the given header name. Header names are case-insensitive and normalized to a lowercase string.
- (NSArray<NSString *> * _Nullable) valuesForHeader:(NSString * _Nonnull)headerName;

/// Return all headers
- (NSDictionary<NSString *, NSArray<NSString *> *> * _Nonnull) allHeaders;

@end

NS_ASSUME_NONNULL_END
