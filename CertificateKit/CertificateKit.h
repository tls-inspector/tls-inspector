//
//  CertificateKit.h
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

#import <UIKit/UIKit.h>

//! Project version number for CertificateKit.
FOUNDATION_EXPORT double CertificateKitVersionNumber;

//! Project version string for CertificateKit.
FOUNDATION_EXPORT const unsigned char CertificateKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CertificateKit/PublicHeader.h>
#import <CertificateKit/CKCertificate.h>
#import <CertificateKit/CKCertificatePublicKey.h>
#import <CertificateKit/CKCertificateChain.h>
#import <CertificateKit/CKServerInfo.h>
#import <CertificateKit/CKGetter.h>
#import <CertificateKit/CKRevoked.h>
#import <CertificateKit/CKOCSPResponse.h>
#import <CertificateKit/CKCRLResponse.h>
#import <CertificateKit/CKGetterOptions.h>
#import <CertificateKit/CKLogging.h>

/**
 Interface for global CertificateKit methods.
 */
@interface CertificateKit : NSObject

typedef NS_ENUM(NSInteger, CKCertificateError) {
    // Errors relating to connecting to the remote server.
    CKCertificateErrorConnection,
    // Crypto error usually resulting from being run on an unsupported platform.
    CKCertificateErrorCrypto,
    // Invalid parameter information such as hostnames.
    CKCertificateErrorInvalidParameter
};

/**
 *  Get the OpenSSL version used by CKCertificate
 *
 *  @return (NSString *) The OpenSSL version E.G. "1.1.0e"
 */
+ (NSString * _Nonnull) opensslVersion;

/**
 Convience method to get the version of libcurl used by CKServerInfo
 
 @return A string representing the libcurl version
 */
+ (NSString * _Nonnull) libcurlVersion;

/**
 Is a HTTP proxy configured on the device
 */
+ (BOOL) isProxyConfigured;

@end
