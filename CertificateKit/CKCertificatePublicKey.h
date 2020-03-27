//
//  CKCertificatePublicKey.h
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
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
#import "CKCertificate.h"

@class CKCertificate;

/**
 X.509 Certificate public key information
 */
@interface CKCertificatePublicKey : NSObject

/**
 The algroithm of the public key, as a string.
 */
@property (strong, nonatomic, nonnull, readonly) NSString * algroithm;
/**
 The length of the public key in bits.
 */
@property (nonatomic, readonly) int bitLength;

/**
 Is this public key a weak RSA key?
 (<2048 bits)
 */
- (BOOL) isWeakRSA;

/**
 Populate a public key info model with information from the given CKCertificate.

 @param cert The CKCertificate to populate the model from.
 @return A populated model or nil on error.
 */
+ (CKCertificatePublicKey * _Nullable) infoFromCertificate:(CKCertificate * _Nonnull)cert;

@end
