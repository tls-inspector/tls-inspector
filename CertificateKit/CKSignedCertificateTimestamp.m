//
//  CKSignedCertificateTimestamp.m
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

#import "CKSignedCertificateTimestamp.h"
#import "NSData+HexString.h"
#import <openssl/x509.h>

@interface CKSignedCertificateTimestamp ()

@property (strong, nonatomic, readwrite, nonnull) NSString * logId;
@property (strong, nonatomic, readwrite, nonnull) NSDate * timestamp;
@property (strong, nonatomic, readwrite, nonnull) NSString * signatureType;
@property (strong, nonatomic, readwrite, nonnull) NSString * signature;

@end

@implementation CKSignedCertificateTimestamp

- (CKSignedCertificateTimestamp *) initWithLogId:(NSData *)logId timestamp:(NSDate *)timestamp signatureType:(NSString *)signatureType signature:(NSData *)signature {
    self = [super init];

    self.logId = [logId hexString];
    self.timestamp = timestamp;
    self.signatureType = signatureType;
    self.signature = [signature hexString];

    return self;
}

@end
