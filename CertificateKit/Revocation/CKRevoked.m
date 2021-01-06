//
//  CKRevoked.m
//
//  LGPLv3
//
//  Copyright (c) 2018 Ian Spence
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

#import "CKRevoked.h"

@interface CKRevoked ()

@property (nonatomic, readwrite) BOOL isRevoked;
@property (strong, nonatomic, nullable, readwrite) NSString * reasonString;
@property (strong, nonatomic, nullable, readwrite) NSDate * revokedOn;
@property (nonatomic, readwrite) CKRevokedUsing revokedUsing;
@property (strong, nonatomic, nullable, readwrite) CKOCSPResponse * ocspResponse;
@property (strong, nonatomic, nullable, readwrite) CKCRLResponse * crlResponse;

@end

@implementation CKRevoked

+ (CKRevoked *) fromOCSPResponse:(CKOCSPResponse *)response {
    return [CKRevoked fromOCSPResponse:response andCRLResponse:nil];
}

+ (CKRevoked *) fromCRLResponse:(CKCRLResponse *)response {
    return [CKRevoked fromOCSPResponse:nil andCRLResponse:response];
}

+ (CKRevoked *) fromOCSPResponse:(CKOCSPResponse *)ocspResponse andCRLResponse:(CKCRLResponse *)crlResponse {
    CKRevoked * revoked = [CKRevoked new];
    if (ocspResponse != nil) {
        revoked.revokedUsing |= CKRevokedUsingOCSP;
        revoked.ocspResponse = ocspResponse;
        
        if (ocspResponse.status == CKOCSPResponseStatusRevoked) {
            revoked.isRevoked = YES;
            revoked.reasonString = ocspResponse.reasonString;
        } else {
            revoked.isRevoked = NO;
        }
    }
    if (crlResponse != nil) {
        revoked.revokedUsing |= CKRevokedUsingCRL;
        revoked.crlResponse = crlResponse;
        
        if (crlResponse.status == CKCRLResponseStatusRevoked) {
            revoked.revokedOn = crlResponse.revokedOn;
            revoked.isRevoked = YES;
        }
    }
    return revoked;
}

@end
