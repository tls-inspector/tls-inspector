//
//  CKOCSPManager.h
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
#import "CKCertificate.h"

@interface CKOCSPManager : NSObject

typedef NS_ENUM(int, OCSPResponse) {
    OCSPResponseSuccess             = 0,
    OCSPResponseMalformedRequest    = 1,
    OCSPResponseServerError         = 2,
    OCSPResponseTryServerLater      = 3,
    OCSPResponseRequestNeedsSig     = 5,
    OCSPResponseUnauthorizedRequest = 6,
    OCSPResponseUnknown,
};

+ (CKOCSPManager * _Nonnull) sharedManager;
- (void) queryCertificate:(CKCertificate * _Nonnull)certificate finished:(void (^ _Nonnull)(NSError * _Nullable error))finished;

@end
