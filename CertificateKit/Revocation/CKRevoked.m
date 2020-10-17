//
//  CKRevoked.m
//
//  MIT License
//
//  Copyright (c) 2018 Ian Spence
//  https://tlsinspector.com/github.html
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
