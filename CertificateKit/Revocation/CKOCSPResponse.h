//
//  CKOCSPResponse.h
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
 Describes a OCSP response object
 */
@interface CKOCSPResponse : NSObject

/**
 Possible response status'.

 - CKOCSPResponseStatusOK: The "good" state indicates a positive response to the status inquiry.
                           At a minimum, this positive response indicates that the certificate
                           is not revoked, but does not necessarily mean that the certificate
                           was ever issued or that the time at which the response was produced
                           is within the certificate's validity interval. Response extensions
                           may be used to convey additional information on assertions made by
                           the responder regarding the status of the certificate such as
                           positive statement about issuance, validity, etc.
 - CKOCSPResponseStatusRevoked: The "revoked" state indicates that the certificate has been revoked
                                (either permanantly or temporarily (on hold)).
 - CKOCSPResponseStatusUnknown: The "unknown" state indicates that the responder doesn't know about
                                the certificate being requested.
 */
typedef NS_ENUM(NSUInteger, CKOCSPResponseStatus) {
    CKOCSPResponseStatusOK = 0,
    CKOCSPResponseStatusRevoked = 1,
    CKOCSPResponseStatusUnknown = 2,
};

/**
 The response status from the OCSP request.
 */
@property (nonatomic) CKOCSPResponseStatus status;

/**
 The reason code given by the OCSP responder for a revoked certificate (if any). Only applies to revoked certificates.
 */
@property (nonatomic) NSUInteger reason;

@end
