//
//  CKCRLResponse.h
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

/**
 Describes a CRL response object
 */
@interface CKCRLResponse : NSObject

/**
 Possible status values resulting from checking a CRL

 - CKCRLResponseStatusRevoked: The certificate is revoked according to this CRL
 - CKCRLResponseStatusNotFound: The certificate was not found in the CRL. This doesn't
 mean that the certificate isn't revoked, just that the queried CRL didn't have that certificate
 in it.
 */
typedef NS_ENUM(NSUInteger, CKCRLResponseStatus) {
    CKCRLResponseStatusRevoked = 1,
    CKCRLResponseStatusNotFound = 2,
};

/**
 The response status from the CRL request.
 */
@property (nonatomic) CKCRLResponseStatus status;

/**
 The reason code given by the CRL responder for a revoked certificate (if any). Only applies to revoked certificates.
 */
@property (nonatomic) NSUInteger reason;

/**
 The date (if any) the certificate was revoked.
 */
@property (strong, nonatomic, nullable) NSDate * revokedOn;

@end

