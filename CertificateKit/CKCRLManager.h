//
//  CKCRLManager.h
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

/**
 CKCRLManager is an interface for managing and querying certificate revocation lists
 */
@interface CKCRLManager : NSObject

/**
 Get or create the CRL Manager singleton

 @return A CKCRLManager singleton instance
 */
+ (CKCRLManager * _Nonnull) sharedInstance;

/**
 Get or create the CRL Manager singleton

 @return A CKCRLManager singleton instance
 */
- (id _Nonnull) init;

/**
 Load the CRL cache from disk. Due to the potential size of the cache, ensure you unload the cache
 when you're finished using it.
 */
- (void) loadCRLCache;

/**
 Flush the CRL cache to disk, and unload it from memory.
 */
- (void) unloadCRLCache;

/**
 Get the CRL data for the given CRL URL

 @param crl The URL of the CRL
 @param finished Called with the data of the CRL or an error
 */
- (void) getCRL:(NSURL * _Nonnull)crl finished:(void (^ _Nonnull)(NSData * _Nullable data, NSError * _Nullable error))finished;

@end
