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

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <openssl/x509.h>

@interface CHCertificate : NSObject <NSURLSessionDelegate> {
    NSData * certificateData;
}

typedef NS_ENUM(NSInteger, kFingerprintType) {
    kFingerprintTypeSHA256,
    // Dangerous! Avoid using these.
    kFingerprintTypeSHA1,
    kFingerprintTypeMD5
};

/**
 *  Creates a new CHCertificate object with the certificate reference
 *
 *  @param cert A SecCertificateRef reference to the cert object
 *
 *  @return an instatiated CHCertificate object
 */
+ (CHCertificate *) withCertificateRef:(SecCertificateRef)cert;

/**
 *  Retrieve the certificate chain for the specified URL
 *
 *  @param URL      The URL to retrieve
 *  @param finished Called when the network request has completed with either an error or an array
 *                  of certificates
 */
- (void) fromURL:(NSString *)URL finished:(void (^)(NSError * error,
                                                    NSArray<CHCertificate *>* certificates,
                                                    BOOL trustedChain))finished;
/**
 *  Determine if the certificate chain is trusted by the systems certificate store
 *
 *  @param trust The SecTrustRef object to evalulate
 *
 *  @return Trusted?
 */
+ (BOOL) trustedChain:(SecTrustRef)trust;

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
 *  Warning! SH1 is no longer considered cryptographically secure - avoide use!
 *
 *  @return A NSString value of the fingerprint
 */
- (NSString *) SHA1Fingerprint;

/**
 *  Verify the fingerprint of the certificate. Useful for certificate pinning.
 *
 *  @param fingerprint The fingerprint
 *  @param type        The type of hashing algrotim used to generate the fingerprint
 *
 *  @return YES if verified
 */
- (BOOL) verifyFingerprint:(NSString *)fingerprint type:(kFingerprintType)type;

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
 *  Retruns an array of dictionaries with the subjet names, and name types (OU or CN)
 *
 *  @return An array of dictionaries: [ { "type": "OU", "name": "*.foo" } ]
 */
- (NSArray<NSDictionary *> *) names;


/**
 *  Returns the public key encoded using Privacy-Enchanged Electronic Mail (PEM).
 *
 *  @return NSData representing the bytes (includes header and footer) or nil on error
 */
- (NSData *) publicKeyAsPEM;

@property (nonatomic) X509 * X509Certificate;
@property (strong, nonatomic) NSString * summary;
@property (strong, nonatomic) NSString * host;
@property (nonatomic) BOOL trusted;
@property (nonatomic) SecCertificateRef cert;

@end
