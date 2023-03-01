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
#import <openssl/ct.h>

@interface CKSignedCertificateTimestamp ()

@property (strong, nonatomic, readwrite, nonnull) NSString * logId;
@property (strong, nonatomic, readwrite, nullable) NSString * logName;
@property (strong, nonatomic, readwrite, nonnull) NSDate * timestamp;
@property (strong, nonatomic, readwrite, nonnull) NSString * signatureType;
@property (strong, nonatomic, readwrite, nonnull) NSString * signature;

@end

@implementation CKSignedCertificateTimestamp

- (CKSignedCertificateTimestamp *) initWithLogId:(NSData *)logId timestamp:(NSDate *)timestamp signatureType:(NSString *)signatureType signature:(NSData *)signature {
    self = [super init];

    self.logId = [logId hexString];
    self.logName = [self findLogName:logId];
    self.timestamp = timestamp;
    self.signatureType = signatureType;
    self.signature = [signature hexString];

    return self;
}

- (NSString *) findLogName:(NSData *)logId {
    NSString * logListPath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"ct_log_list" ofType:@"json"];
    NSDictionary<NSString *, id> * logList = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:logListPath] options:0 error:nil];
    if ([logList valueForKey:@"operators"] == nil) {
        return nil;
    }
    NSString * logIdStr = [logId base64EncodedStringWithOptions:0];

    NSArray<NSDictionary<NSString *, id> *> * operators = logList[@"operators"];
    for (NSDictionary<NSString *, id> * operator in operators) {
        if ([operator valueForKey:@"logs"] == nil) {
            return nil;
        }

        NSArray<NSDictionary<NSString *, id> *> * logs = operator[@"logs"];
        for (NSDictionary<NSString *, id> * log in logs) {
            NSString * operatorLogId = [log valueForKey:@"log_id"];
            if ([operatorLogId isEqualToString:logIdStr]) {
                return [log valueForKey:@"description"];
            }
        }
    }

    return nil;
}

+ (CKSignedCertificateTimestamp *) fromSCT:(void *)sct {
    unsigned char * logidb;
    size_t logIdLength = SCT_get0_log_id((SCT *)sct, &logidb);
    if (logIdLength == 0) {
        return nil;
    }
    NSData * logId = [[NSData alloc] initWithBytes:logidb length:logIdLength];
    int64_t ts = SCT_get_timestamp((SCT *)sct); // milliseconds
    NSDate * timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:ts/1000];

    unsigned char * sigb;
    size_t sigLength = SCT_get0_signature((SCT *)sct, &sigb);
    if (sigLength == 0) {
        return nil;
    }
    NSData * signature = [[NSData alloc] initWithBytes:sigb length:sigLength];

    NSString * sigAlg;
    int nid = SCT_get_signature_nid((SCT *)sct);
    switch (nid) {
        case NID_ecdsa_with_SHA256:
            sigAlg = @"ECDSA with SHA-256";
            break;
        case NID_sha256WithRSAEncryption:
            sigAlg = @"RSA with SHA-256";
            break;
        default:
            sigAlg = @"Unknown";
            break;
    }

    return [[CKSignedCertificateTimestamp alloc] initWithLogId:logId timestamp:timestamp signatureType:sigAlg signature:signature];
}

@end
