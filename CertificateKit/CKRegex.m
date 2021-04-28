//
//  CKRegex.m
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

#import "CKRegex.h"

@interface CKRegex ()

@property (strong, nonatomic) NSRegularExpression * regex;

@end

@implementation CKRegex

+ (CKRegex *) compile:(NSString *)pattern {
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    if (regex == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid regex pattern" userInfo:nil];
    }

    CKRegex * ckregex = [[CKRegex alloc] init];
    ckregex.regex = regex;
    return ckregex;
}

- (NSString *) replaceAllMatchesIn:(NSString *)string with:(NSString *)replace {
    NSMutableString * newString = [NSMutableString stringWithString:string];
    [self.regex replaceMatchesInString:newString options:0 range:NSMakeRange(0, newString.length) withTemplate:replace];
    return newString;
}

- (BOOL) matches:(NSString *)string {
    NSArray<NSTextCheckingResult *> * matches = [self.regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    return matches.count > 0;
}

- (NSString *) firstMatch:(NSString *)string {
    NSArray<NSTextCheckingResult *> * matches = [self.regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (matches.count == 0) {
        return nil;
    }

    return [string substringWithRange:matches[0].range];
}

@end
