//
//  CKSocketUtils.h
//
//  LGPLv3
//
//  Copyright (c) 2020 Ian Spence
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

/// Utilities for working with sockets
@interface CKSocketUtils : NSObject

/// Get the servers (peer) IP address in human-readable format for the given socket
/// @param socket The sockets file descriptor
+ (NSString * _Nullable) remoteAddressForSocket:(int)socket;

@end

NS_ASSUME_NONNULL_END
