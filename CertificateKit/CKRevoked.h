//
//  CKRevoked.h
//
//  MIT License
//
//  Copyright (c) 2018 Ian Spence
//  https://github.com/certificate-helper/CertificateKit
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

#import <Foundation/Foundation.h>
#import "CKOCSPResponse.h"

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
//@property (strong, nonatomic, nullable, readonly) CKCRLResponse * crlResponse;

+ (CKRevoked * _Nonnull) fromOCSPResponse:(CKOCSPResponse * _Nonnull)response;

@end
