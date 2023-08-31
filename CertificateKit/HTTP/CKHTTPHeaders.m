//
//  CKHTTPHeaders.m
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

#import "CKHTTPHeaders.h"

@interface CKHTTPHeaders ()

@property (strong, nonatomic) NSDictionary<NSString *, NSArray<NSString *> *> * values;

@end

@implementation CKHTTPHeaders

- (id) initWithData:(NSData *)data {
    self = [super init];

    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> * values = [NSMutableDictionary new];

    NSArray<NSString *> * lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\r\n"];
    for (NSString * line in lines) {
        NSArray<NSString *> * parts = [line componentsSeparatedByString:@": "];
        if (parts.count < 2) {
            continue;
        }
        NSString * key = [parts[0] lowercaseString];
        NSString * value = [line substringFromIndex:key.length+2];
        NSMutableArray<NSString *> * valuesForKey = values[key];
        if (valuesForKey == nil) {
            valuesForKey = [NSMutableArray new];
        }
        [valuesForKey addObject:value];
        [values setValue:valuesForKey forKey:key];
    }

    self.values = values;

    return self;
}

- (NSString * _Nullable) valueForHeader:(NSString * _Nonnull)headerName {
    NSArray<NSString *> * values = [self valuesForHeader:headerName];
    if (values == nil) {
        return nil;
    }

    return values[0];
}

- (NSArray<NSString *> * _Nullable) valuesForHeader:(NSString * _Nonnull)headerName {
    return self.values[[headerName lowercaseString]];
}

- (NSDictionary<NSString *, NSArray<NSString *> *> * _Nonnull) allHeaders {
    return self.values;
}

- (NSString *) description {
    NSMutableString * desc = [NSMutableString new];

    for (NSString * key in self.values.allKeys) {
        NSArray<NSString *> * values = self.values[key];
        for (NSString * value in values) {
            [desc appendFormat:@"%@: %@\n", key, value];
        }
    }

    return desc;
}

@end
