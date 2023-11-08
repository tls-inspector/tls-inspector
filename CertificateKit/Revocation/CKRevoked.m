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

#import <CertificateKit/CKRevoked.h>
#import <CertificateKit/CKOCSPResponse.h>
#import <CertificateKit/CKCRLResponse.h>
#import <openssl/x509v3.h>

@interface CKRevoked ()

@property (nonatomic, readwrite) BOOL isRevoked;
@property (nonatomic, readwrite) CKRevokedReason reason;
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
            revoked.reason = [CKRevoked reasonFromCRLReason:ocspResponse.reason];
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
            revoked.reason = [CKRevoked reasonFromCRLReason:crlResponse.reason];
        }
    }
    return revoked;
}

+ (CKRevokedReason) reasonFromCRLReason:(NSUInteger)crlReason {
    switch (crlReason) {
        case CRL_REASON_NONE:
            return CKRevokedReasonNone;
        case CRL_REASON_UNSPECIFIED:
            return CKRevokedReasonUnspecified;
        case CRL_REASON_KEY_COMPROMISE:
            return CKRevokedReasonKeyCompromise;
        case CRL_REASON_CA_COMPROMISE:
            return CKRevokedReasonCACompromise;
        case CRL_REASON_AFFILIATION_CHANGED:
            return CKRevokedReasonAffiliationChanged;
        case CRL_REASON_SUPERSEDED:
            return CKRevokedReasonSuperseded;
        case CRL_REASON_CESSATION_OF_OPERATION:
            return CKRevokedReasonCessationOfOperation;
        case CRL_REASON_CERTIFICATE_HOLD:
            return CKRevokedReasonCertificateHold;
        case CRL_REASON_REMOVE_FROM_CRL:
            return CKRevokedReasonRemoveFromCRL;
        case CRL_REASON_PRIVILEGE_WITHDRAWN:
            return CKRevokedReasonPrivilegeWithdrawn;
        case CRL_REASON_AA_COMPROMISE:
            return CKRevokedReasonAACompromise;
        default:
            return CKRevokedReasonUnknown;
    }
}

@end
