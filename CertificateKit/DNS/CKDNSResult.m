//
//  CKDNSResult.m
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

#import <CertificateKit/CKDNSResult.h>

@implementation CKDNSResult

- (NSArray<NSString *> *) addressesForName:(NSString *)name error:(NSError **)error {
    NSMutableString * host = [name mutableCopy];
    if ([host characterAtIndex:host.length-1] != '.') {
        [host appendString:@"."];
    }

    NSMutableArray<NSString *> * values = [NSMutableArray new];
    CKDNSResource * resource;
    for (CKDNSResource * r in self.resources) {
        if (![r.name isEqualToString:host]) {
            continue;
        }

        resource = r;
        [values addObject:r.value];
    }
    if (resource == nil || values.count == 0) {
        *error = MAKE_ERROR(1, @"Not found");
        return nil;
    }

    if (resource.recordType == CKDNSRecordTypeCNAME) {
        NSString * nextName = resource.value;
        int depth = 0;
        while (depth < 10) {
            NSMutableArray<NSString *> * targetValues = [NSMutableArray new];
            for (CKDNSResource * r in self.resources) {
                if (![r.name isEqualToString:nextName]) {
                    continue;
                }

                if (r.recordType == CKDNSRecordTypeCNAME) {
                    nextName = r.value;
                    depth++;
                } else {
                    [targetValues addObject:r.value];
                }
            }
            if (targetValues.count > 0) {
                return targetValues;
            }
        }
        PDebug(@"[DOH] CNAME loop detected");
        *error = MAKE_ERROR(1, @"CNAME loop detected");
        return nil;
    }

    return values;
}

@end
