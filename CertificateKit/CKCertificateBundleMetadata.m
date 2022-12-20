//
//  CKCertificateBundleMetadata.m
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

#import "CKCertificateBundleMetadata.h"

@interface CKCertificateBundleMetadata ()

@property (strong, nonatomic, readwrite, nullable) NSDate * bundleDate;
@property (strong, nonatomic, readwrite, nullable) NSString * bundleSHA256;
@property (strong, nonatomic, readwrite, nullable) NSNumber * certificateCount;

@end

@implementation CKCertificateBundleMetadata

+ (CKCertificateBundleMetadata *) metadataFrom:(NSDictionary<NSString *,id> *)dictionary {
    NSDate * bundleDate;
    NSString * bundleSHA256;
    NSNumber * certificateCount;

    if ([dictionary valueForKey:@"date"] != nil) {
        NSDateFormatter * formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        bundleDate = [formatter dateFromString:dictionary[@"date"]];
    } else {
        return nil;
    }
    bundleSHA256 = dictionary[@"sha_256"];
    certificateCount = dictionary[@"num_certs"];

    return [[CKCertificateBundleMetadata alloc] initWithDate:bundleDate bundleSHA256:bundleSHA256 certificateCount:certificateCount];
}

- (CKCertificateBundleMetadata *) initWithDate:(NSDate *)date bundleSHA256:(NSString *)bundleSHA256 certificateCount:(NSNumber *)certificateCount {
    self = [super init];
    self.bundleDate = date;
    self.bundleSHA256 = bundleSHA256;
    self.certificateCount = certificateCount;
    return self;
}

@end
