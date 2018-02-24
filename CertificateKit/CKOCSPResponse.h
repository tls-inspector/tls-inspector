//
//  CKOCSPResponse.h
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
 The reason given by the OCSP responder for a revoked certificate (if any). Only applies to revoked certificates.
 */
@property (strong, nonatomic, nullable) NSString * reasonString;

/**
 The reason code given by the OCSP responder for a revoked certificate (if any). Only applies to revoked certificates.
 */
@property (nonatomic) NSUInteger reason;

@end
