//
//  CKGetter.h
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
#import "CKCertificateChain.h"
#import "CKServerInfo.h"
#import "CKGetterParameters.h"

/**
 CKGetter is the interface used to get all information about a specific domain. Used to track progress
 of all of the required requests
 */
@interface CKGetter : NSObject

/**
 Begin the process of inspecting the URL specified in the parameters.

 @param parameters The parameters for the getter.
 */
- (void) getInfo:(CKGetterParameters * _Nonnull)parameters;

/**
 The object that conforms to the CKGetterDelegate protocol
 */
@property (weak, nonatomic, nullable) id delegate;

/**
 The inspected URL
 */
@property (strong, nonatomic, nonnull) NSURL * url;
/**
 Options for the getter
 */
@property (strong, nonatomic, nonnull) CKGetterParameters * parameters;

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

@required

/**
 Called when the getter has finished all of its tasks

 @param getter The getter
 @param success If the getter was successful
 */
- (void) finishedGetter:(CKGetter * _Nonnull)getter successful:(BOOL)success;
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
 Called when the getter experienced an unexpected error outside of the context of getting the certificate chain or server info

 @param getter The getter
 @param error The error
 */
- (void) getter:(CKGetter * _Nonnull)getter unexpectedError:(NSError * _Nonnull)error;
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
