//
//  CKGetter.h
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
#import "CKCertificateChain.h"
#import "CKServerInfo.h"
#import "CKGetterOptions.h"

/**
 CKGetter is the interface used to get all information about a specific domain. Used to track progress
 of all of the required requests
 */
@interface CKGetter : NSObject

/**
 Initalize a new CKGetter with specified options

 @param options options for the CKGetter
 @return A CKGetter instance
 */
+ (CKGetter * _Nonnull) getterWithOptions:(CKGetterOptions * _Nonnull)options;

/**
 Get information for the given URL. This will start the getter process and make all required requests for
 certificate, server information, and potentially more.

 @param URL The URL to query. Does not have to start with https:// and any path will be ignored.
            Can contain a port number.
 */
- (void) getInfoForURL:(NSURL * _Nonnull)URL;

/**
 The object that conforms to the CKGetterDelegate protocol
 */
@property (weak, nonatomic, nullable) id delegate;

/**
 Options for the getter
 */
@property (strong, nonatomic, nonnull) CKGetterOptions * options;

/**
 The certificate chain for the URL
 */
@property (strong, nonatomic, nullable) CKCertificateChain * chain;
/**
 The server info for the URL
 */
@property (strong, nonatomic, nullable) CKServerInfo * serverInfo;

@end

/**
 Protocol for visibility into the status of the getter
 */
@protocol CKGetterDelegate

/**
 Called when the getter has finished all of its task only if all succeeded

 @param getter The getter
 */
- (void) finishedGetter:(CKGetter * _Nonnull)getter;
/**
 Called when the getter has finished getting the certificate chian

 @param getter The getter
 @param chain The certificate chian
 */
- (void) getter:(CKGetter * _Nonnull)getter gotCertificateChain:(CKCertificateChain * _Nonnull)chain;
/**
 Called when the getter has finished getting the server info

 @param getter The getter
 @param serverInfo The server info
 */
- (void) getter:(CKGetter * _Nonnull)getter gotServerInfo:(CKServerInfo * _Nonnull)serverInfo;
/**
 Called when the getter experienced an error getting the certificate chain

 @param getter The getter
 @param error The error
 */
- (void) getter:(CKGetter * _Nonnull)getter errorGettingCertificateChain:(NSError * _Nonnull)error;
/**
 Called when the getter expereinced an error getting the server info

 @param getter The getter
 @param error The error
 */
- (void) getter:(CKGetter * _Nonnull)getter errorGettingServerInfo:(NSError * _Nonnull)error;

@end
