//
//  CKHTTPResponse.h
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
#import <CertificateKit/CKHTTPHeaders.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKHTTPResponse : NSObject

/// The host of this HTTP server
@property (nonatomic, nonnull, readonly) NSString * host;

/// The HTTP status code
@property (nonatomic, readonly) NSUInteger statusCode;

/// Response headers
@property (strong, nonatomic, nonnull, readonly) CKHTTPHeaders * headers;

- (id) initWithHost:(NSString *)host statusCode:(NSUInteger)statusCode headers:(CKHTTPHeaders *)headers;

@end

NS_ASSUME_NONNULL_END
