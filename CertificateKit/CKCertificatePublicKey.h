//
//  CKCertificatePublicKey.h
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
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
