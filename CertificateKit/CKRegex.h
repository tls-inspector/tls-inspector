//
//  CKRegex.h
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

NS_ASSUME_NONNULL_BEGIN

/// Provides a easier regular expression API than the stock Apple one
@interface CKRegex : NSObject


/// Compile the provided regular expression pattern into a new regex object.
/// @param pattern The regular expression pattern.
/// @throws Will throw if the pattern is invalid
+ (CKRegex * _Nonnull) compile:(NSString * _Nonnull)pattern;

/// Replace all matches with new values. Returns a new string.
/// @param string The string to update
/// @param replace The new value that matches should be changed to.
- (NSString *) replaceAllMatchesIn:(NSString * _Nonnull)string with:(NSString * _Nonnull)replace;

/// Does this pattern match the given string.
/// @param string The string to check.
- (BOOL) matches:(NSString * _Nonnull)string;

/// Get the first match, if any, from the given string.
/// @param string The string to check.
- (NSString * _Nullable) firstMatch:(NSString * _Nonnull)string;

@end

NS_ASSUME_NONNULL_END
