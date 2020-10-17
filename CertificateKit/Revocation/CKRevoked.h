//
//  CKRevoked.h
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

#import <Foundation/Foundation.h>
#import "CKOCSPResponse.h"
#import "CKCRLResponse.h"

/**
 An object describing information about a certificates revocation status.
 */
@interface CKRevoked : NSObject

/**
 Possible ways a certificate could be revoked.

 - CKRevokedUsingOCSP: The online certificate status protocol.
 - CKRevokedUsingCRL: A certificate revocation list.
 */
typedef NS_ENUM(NSUInteger, CKRevokedUsing) {
    CKRevokedUsingOCSP = 1,
    CKRevokedUsingCRL  = 2,
};

/**
 Is this certificate revoked.
 */
@property (nonatomic, readonly) BOOL isRevoked;
/**
 If revoked, what is the reason it was revoked.
 */
@property (strong, nonatomic, nullable, readonly) NSString * reasonString;
/**
 If revoked, what was the date it was revoked (CRL only).
 */
@property (strong, nonatomic, nullable, readonly) NSDate * revokedOn;
/**
 Which method was used to determine the certificate was revoked. Bitflag.
 */
@property (nonatomic, readonly) CKRevokedUsing revokedUsing;

/**
 The OCSP response information, if OCSP was used.
 */
@property (strong, nonatomic, nullable, readonly) CKOCSPResponse * ocspResponse;
/**
 The CRL response information, if CRL was used.
 */
@property (strong, nonatomic, nullable, readonly) CKCRLResponse * crlResponse;

+ (CKRevoked * _Nonnull) fromOCSPResponse:(CKOCSPResponse * _Nonnull)response;
+ (CKRevoked * _Nonnull) fromCRLResponse:(CKCRLResponse * _Nonnull)response;
+ (CKRevoked * _Nonnull) fromOCSPResponse:(CKOCSPResponse * _Nullable)ocspResponse andCRLResponse:(CKCRLResponse * _Nullable)crlResponse;

@end
