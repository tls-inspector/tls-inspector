//
//  CKCRLResponse.h
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
 The reason given by the CRL responder for a revoked certificate (if any). Only applies to revoked certificates.
 */
@property (strong, nonatomic, nullable) NSString * reasonString;

/**
 The reason code given by the CRL responder for a revoked certificate (if any). Only applies to revoked certificates.
 */
@property (nonatomic) NSUInteger reason;

/**
 The date (if any) the certificate was revoked.
 */
@property (strong, nonatomic, nullable) NSDate * revokedOn;

@end

