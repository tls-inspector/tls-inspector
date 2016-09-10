//
//  CHCertificate.h
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
//  https://github.com/ecnepsnai/CHCertificate
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

FOUNDATION_EXPORT double CHXertificateVersionNumber;
FOUNDATION_EXPORT const unsigned char CHXertificateVersionString[];

#import <Foundation/Foundation.h>

@interface CHCertificate : NSObject

/**
 *  Query the specified URL for its certificate chain.
 *
 *  @param URL      The URL to query. Must use the https scheme.
 *                  The port is optional and will default to 443.
 *  @param finished Called when finished with either an error or certificates.
 */
+ (void) certificateChainFromURL:(NSURL *)URL finished:(void (^)(NSError * error,
                                                                 NSArray<CHCertificate *> * certificates,
                                                                 BOOL trustedChain))finished;

/**
 *  Create a CHCertificate object from a pre-existing X509 object.
 *
 *  @param cert A libssl compliant X509 cert.
 *
 *  @return A CHCertificate instance
 */
+ (CHCertificate *) fromX509:(void *)cert;

typedef NS_ENUM(NSInteger, CHCertificateFingerprintType) {
    // SHA 512 fingerprint type
    CHCertificateFingerprintTypeSHA512,
    // SHA 256 fingerprint type
    CHCertificateFingerprintTypeSHA256,
    // MD5 fingerprint type
    CHCertificateFingerprintTypeMD5,
    // SHA1 fingerprint type
    CHCertificateFingerprintTypeSHA1
};

typedef NS_ENUM(NSInteger, CHCertificateError) {
    // Errors relating to connecting to the remote server.
    CHCertificateErrorConnection,
    // Crypto error usually resulting from being run on an unsupported platform.
    CHCertificateErrorCrypto,
    // Invalid parameter information such as hostnames.
    CHCertificateErrorInvalidParameter
};

@property (strong, nonatomic, readonly) NSString * summary;

/**
 *  Returns the SHA256 fingerprint for the certificate
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) SHA256Fingerprint;

/**
 *  Returns the MD5 fingerprint for the certificate
 *
 *  Warning! The security of the MD5 algorithm has been seriously compromised - avoid use!
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) MD5Fingerprint;

/**
 *  Returns the SHA1 fingerprint for the certificate
 *
 *  Warning! SH1 is no longer considered cryptographically secure - avoid use!
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) SHA1Fingerprint;

/**
 *  Verify the fingerprint of the certificate. Useful for certificate pinning.
 *
 *  @param fingerprint The fingerprint
 *  @param type        The type of hashing method used to generate the fingerprint
 *
 *  @return YES if verified
 */
- (BOOL) verifyFingerprint:(NSString *)fingerprint type:(CHCertificateFingerprintType)type;

/**
 *  Returns the serial number for the certificate
 *
 *  @return A NSString value of the serial number
 */
- (NSString *) serialNumber;

/**
 *  Returns the human readable signature algorithm
 *
 *  @return A NSString value of the algorithm
 */
- (NSString *) algorithm;

/**
 *  Returns the expiry date for the certificate
 *
 *  @return A NSDate object for the "not after" field - Time is not critical for this date object.
 */
- (NSDate *) notAfter;

/**
 *  Returns the start date for the certificate
 *
 *  @return A NSDate object for the "not before" field - Time is not critical for this date object.
 */
- (NSDate *) notBefore;

/**
 *  Test if current date is within the certificates issue date range
 *
 *  @return current date within range?
 */
- (BOOL) validIssueDate;

/**
 *  Retuns the issuer name
 *
 *  @return A NSString value of the issuer identity
 */
- (NSString *) issuer;

/**
 *  Retruns an array of dictionaries with the subject names, and name types (OU or CN)
 *
 *  @return An array of dictionaries: [ { "type": "OU", "name": "*.foo" } ]
 */
- (NSDictionary<NSString *, NSString *> *) names;


/**
 *  Returns the public key encoded using Privacy-Enhanced Electronic Mail (PEM).
 *
 *  @return NSData representing the bytes (includes header and footer) or nil on error
 */
- (NSData *) publicKeyAsPEM;

@end
