//
//  CertificateKit.h
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

#import <UIKit/UIKit.h>

//! Project version number for CertificateKit.
FOUNDATION_EXPORT double CertificateKitVersionNumber;

//! Project version string for CertificateKit.
FOUNDATION_EXPORT const unsigned char CertificateKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CertificateKit/PublicHeader.h>
#import <CertificateKit/CKCertificate.h>
#import <CertificateKit/CKCertificatePublicKey.h>
#import <CertificateKit/CKCertificateChain.h>
#import <CertificateKit/CKCertificateChain+EnumValues.h>
#import <CertificateKit/CKServerInfo.h>
#import <CertificateKit/CKGetter.h>
#import <CertificateKit/CKRevoked.h>
#import <CertificateKit/CKOCSPResponse.h>
#import <CertificateKit/CKCRLResponse.h>
#import <CertificateKit/CKGetterOptions.h>

/**
 Interface for global CertificateKit methods.
 */
@interface CertificateKit : NSObject

/**
 Logging levels for the certificate kit log

 - CKLoggingLevelDebug: Debug logs will include all information sent to the log instance,
                        including domain names. Use with caution.
 - CKLoggingLevelInfo: Informational logs for irregular, but not dangerous events.
 - CKLoggingLevelWarning: Warning logs for dangerous, but not fatal events.
 - CKLoggingLevelError: Error events for when things really go sideways.
 */
typedef NS_ENUM(NSUInteger, CKLoggingLevel) {
    CKLoggingLevelDebug = 0,
    CKLoggingLevelInfo,
    CKLoggingLevelWarning,
    CKLoggingLevelError,
};

/**
 *  Get the OpenSSL version used by CKCertificate
 *
 *  @return (NSString *) The OpenSSL version E.G. "1.1.0e"
 */
+ (NSString *) opensslVersion;

/**
 Convience method to get the version of libcurl used by CKServerInfo
 
 @return A string representing the libcurl version
 */
+ (NSString *) libcurlVersion;

/**
 Set the minimum level for which logs of that or greater levels will be recorded
 in the CertificateKit log file.

 @param level The log level
 */
+ (void) setLoggingLevel:(CKLoggingLevel)level;

@end
