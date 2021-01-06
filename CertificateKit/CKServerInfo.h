//
//  CKServerInfo.h
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
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

/**
 CKServerInfo is a interface containing information about a HTTPS protected server
 */
@interface CKServerInfo : NSObject

/**
 A dictionary of all response headers recieved when querying the domain
 */
@property (strong, nonatomic, nonnull) NSDictionary<NSString *, NSString *> * headers;
/**
 A dictionary of all security response headers mapped to a (NSNumber)BOOL of if the header was present
 */
@property (strong, nonatomic, nonnull) NSDictionary<NSString *, id> * securityHeaders;
/**
 The HTTP status code seen when querying the domain
 */
@property (nonatomic) NSUInteger statusCode;

/**
 The URL that the server redirected to, if any.
 */
@property (strong, nonatomic, nullable) NSURL * redirectedTo;

@end
