//
//  CKCertificateChainGetter.m
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
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

#import "CKCertificateChainGetter.h"
#import "CKCertificate.h"
#import "CKCertificateChain.h"
#import "CKOCSPManager.h"
#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>

@interface CKCertificateChainGetter () <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream   * inputStream;
    NSOutputStream  * outputStream;
    NSURL * queryURL;
}

@property (strong, nonatomic, readwrite) NSString * domain;
@property (strong, nonatomic, readwrite) NSArray<CKCertificate *> * certificates;
@property (strong, nonatomic, readwrite) CKCertificate * rootCA;
@property (strong, nonatomic, readwrite) CKCertificate * intermediateCA;
@property (strong, nonatomic, readwrite) CKCertificate * server;
@property (nonatomic, readwrite) CKCertificateChainTrustStatus trusted;
@property (nonatomic, readwrite) SSLCipherSuite cipher;
@property (nonatomic, readwrite) SSLProtocol protocol;
@property (nonatomic, readwrite) BOOL crlVerified;
@property (strong, nonatomic) CKCertificateChain * chain;

@end

@implementation CKCertificateChainGetter

- (void) performTaskForURL:(NSURL *)url {
    PDebug(@"Getting certificate chain");
    queryURL = url;
    unsigned int port = queryURL.port != nil ? [queryURL.port unsignedIntValue] : 443;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)url.host, port, &readStream, &writeStream);

    outputStream = (__bridge NSOutputStream *)writeStream;
    inputStream = (__bridge NSInputStream *)readStream;

    inputStream.delegate = self;
    outputStream.delegate = self;

    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    [outputStream open];
    [inputStream open];
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    switch (event) {
        case NSStreamEventOpenCompleted: {
            [self streamOpened:stream];
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            [self streamHasSpaceAvailable:stream];
            break;
        }

        case NSStreamEventHasBytesAvailable:
        case NSStreamEventNone: {
            break;
        }

        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered: {
            PError(@"NSStream error occured: %@", stream.streamError.description);
            [self.delegate getter:self failedTaskWithError:[stream streamError]];
            [inputStream close];
            [outputStream close];
            break;
        }
    }
}

- (void) streamOpened:(NSStream *)stream {
    NSDictionary *settings = @{
                               (__bridge NSString *)kCFStreamSSLValidatesCertificateChain: (__bridge NSNumber *)kCFBooleanFalse
                               };
    CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
}

- (void) streamHasSpaceAvailable:(NSStream *)stream {
    SecTrustRef trust = (__bridge SecTrustRef)[stream propertyForKey: (__bridge NSString *)kCFStreamPropertySSLPeerTrust];
    SecTrustResultType trustStatus;

    SecTrustEvaluate(trust, &trustStatus);
    long count = SecTrustGetCertificateCount(trust);

    NSMutableArray<CKCertificate *> * certs = [NSMutableArray arrayWithCapacity:count];

    for (long i = 0; i < count; i ++) {
        SecCertificateRef certificateRef = SecTrustGetCertificateAtIndex(trust, i);
        NSData * certificateData = (NSData *)CFBridgingRelease(SecCertificateCopyData(certificateRef));
        const unsigned char * bytes = (const unsigned char *)[certificateData bytes];
        // This will leak
        X509 * cert = d2i_X509(NULL, &bytes, [certificateData length]);
        certificateData = nil;
        [certs setObject:[CKCertificate fromX509:cert] atIndexedSubscript:i];
    }

    SSLContextRef context = (SSLContextRef)CFReadStreamCopyProperty((__bridge CFReadStreamRef) inputStream, kCFStreamPropertySSLContext);
    size_t numCiphers;
    SSLGetNumberEnabledCiphers(context, &numCiphers);
    SSLCipherSuite * ciphers = malloc(numCiphers);
    SSLGetNegotiatedCipher(context, ciphers);

    SSLProtocol protocol = 0;
    SSLGetNegotiatedProtocolVersion(context, &protocol);

    [inputStream close];
    [outputStream close];
    
    PDebug(@"Domain: '%@' trust result: '%@' (%d)", queryURL, [self trustResultToString:trustStatus], trustStatus);

    self.chain = [CKCertificateChain new];
    self.chain.certificates = certs;

    self.chain.domain = queryURL.host;
    
    if (certs.count == 0) {
        PError(@"No certificates presented by server");
        [self.delegate getter:self failedTaskWithError:[NSError errorWithDomain:@"CKCertificate" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No certificates presented by server."}]];
        return;
    }
    
    self.chain.server = certs[0];
    if (certs.count > 2) {
        self.chain.rootCA = [certs lastObject];
        self.chain.rootCA.isRootCA = YES;
        self.chain.intermediateCA = [certs objectAtIndex:1];
    } else if (certs.count == 2) {
        self.chain.rootCA = [certs lastObject];
        self.chain.rootCA.isRootCA = YES;
    }
    
    if (certs.count > 1) {
        self.chain.server.revoked = [self getRevokedInformationForCertificate:certs[0] issuer:certs[1]];
    }
    if (certs.count > 2) {
        self.chain.intermediateCA.revoked = [self getRevokedInformationForCertificate:certs[1] issuer:certs[2]];
    }
    
    if (trustStatus == kSecTrustResultUnspecified) {
        self.chain.trusted = CKCertificateChainTrustStatusTrusted;
    } else if (trustStatus == kSecTrustResultProceed) {
        self.chain.trusted = CKCertificateChainTrustStatusLocallyTrusted;
    } else {
        [self determineTrust];
    }

    self.chain.cipher = ciphers[0];
    self.chain.protocol = protocol;
    if (certs.count > 1) {
        self.chain.rootCA = [self.chain.certificates lastObject];
        self.chain.intermediateCA = [self.chain.certificates objectAtIndex:1];
    }

    PDebug(@"Finished getting certificate chain");
    [self.delegate getter:self finishedTaskWithResult:self.chain];
    self.finished = YES;
}

- (CKRevoked *) getRevokedInformationForCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer {
    CKOCSPResponse * ocspResponse;
    CKCRLResponse * crlResponse;
    NSError * ocspError;
    NSError * crlError;
    
    if (self.options.checkOCSP) {
        [[CKOCSPManager sharedManager] queryCertificate:certificate issuer:issuer response:&ocspResponse error:&ocspError];
        if (ocspError != nil) {
            PError(@"OCSP Error: %@", ocspError.description);
        }
    }
    if (self.options.checkCRL) {
        [[CKCRLManager sharedManager] queryCertificate:certificate issuer:issuer response:&crlResponse error:&crlError];
        if (crlError != nil) {
            PError(@"CRL Error: %@", crlError.description);
        }
    }
    return [CKRevoked fromOCSPResponse:ocspResponse andCRLResponse:crlResponse];
}

// Apple does not provide (as far as I am aware) detailed information as to why a certificate chain
// failed evalulation. Therefor we have to made some deductions based off of information we do know.
// Expired (Any)
- (void) determineTrust {
    // Expired/Not Valid
    for (CKCertificate * cert in self.chain.certificates) {
        if (cert.isExpired) {
            PWarn(@"Certificate: '%@' expired on: %@", cert.subject.commonName, cert.notAfter.description);
            self.chain.trusted = CKCertificateChainTrustStatusInvalidDate;
            return;
        } else if (cert.isNotYetValid) {
            PWarn(@"Certificate: '%@' is not yet valid until: %@", cert.subject.commonName, cert.notBefore.description);
            self.chain.trusted = CKCertificateChainTrustStatusInvalidDate;
            return;
        }
    }

    // SHA-1 Leaf
    if ([self.chain.server.signatureAlgorithm hasPrefix:@"sha1"]) {
        PWarn(@"Certificate: '%@' is using SHA-1", self.chain.server.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusSHA1Leaf;
        return;
    }

    // SHA-1 Intermediate
    if ([self.chain.intermediateCA.signatureAlgorithm hasPrefix:@"sha1"]) {
        PWarn(@"Certificate: '%@' is using SHA-1", self.chain.intermediateCA.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusSHA1Intermediate;
        return;
    }

    // Self-Signed
    if (self.chain.certificates.count == 1) {
        PWarn(@"Chain only contains a single certificate");
        self.chain.trusted = CKCertificateChainTrustStatusSelfSigned;
        return;
    }
    
    // Revoked Leaf
    if (self.chain.server.revoked.isRevoked) {
        PWarn(@"Certificate: '%@' is revoked", self.chain.server.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusRevokedLeaf;
        return;
    }
    
    // Revoked Intermedia
    if (self.chain.intermediateCA.revoked.isRevoked) {
        PWarn(@"Certificate: '%@' is revoked", self.chain.intermediateCA.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusRevokedIntermediate;
        return;
    }

    // Wrong Host
    if (self.chain.server.subjectAlternativeNames.count == 0) {
        PWarn(@"Certificate: '%@' has no subject alternate names", self.chain.server.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }
    BOOL match = NO;
    NSArray<NSString *> * domainComponents = [self.chain.domain.lowercaseString componentsSeparatedByString:@"."];
    for (NSString * name in self.chain.server.subjectAlternativeNames) {
        NSArray<NSString *> * nameComponents = [name.lowercaseString componentsSeparatedByString:@"."];
        if (domainComponents.count != nameComponents.count) {
            // Invalid
            continue;
        }

        // SAN Rules:
        //
        // Only the first component of the SAN can be a wildcard
        // Valid: *.google.com
        // Invalid: mail.*.google.com
        //
        // Wildcards only match the same-level of the domain. I.E. *.google.com:
        // Match: mail.google.com
        // Match: calendar.google.com
        // Doesn't match: beta.mail.google.com
        BOOL hasWildcard = [nameComponents[0] isEqualToString:@"*"];
        BOOL validComponents = YES;
        for (int i = 0; i < nameComponents.count; i++) {
            if (i == 0) {
                if (![domainComponents[i] isEqualToString:nameComponents[i]] && !hasWildcard) {
                    validComponents = NO;
                    break;
                }
            } else {
                if (![domainComponents[i] isEqualToString:nameComponents[i]]) {
                    validComponents = NO;
                    break;
                }
            }
        }
        if (validComponents) {
            match = YES;
            break;
        }
    }
    if (!match) {
        PWarn(@"Certificate: '%@' has no subject alternate names that match: '%@'", self.chain.server.subject.commonName, self.chain.domain);
        self.chain.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }

    // Fallback (We don't know)
    PWarn(@"Unable to determine why certificate: '%@' is untrusted", self.chain.server.subject.commonName);
    self.chain.trusted = CKCertificateChainTrustStatusUntrusted;
    return;
}

- (NSString *) trustResultToString:(SecTrustResultType)result {
    switch (result) {
        case kSecTrustResultInvalid:
            return @"Invalid";
            break;
        case kSecTrustResultProceed:
            return @"Proceed";
            break;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        case kSecTrustResultConfirm:
            return @"Confirm";
            break;
#pragma clang diagnostic pop
        case kSecTrustResultDeny:
            return @"Deny";
            break;
        case kSecTrustResultUnspecified:
            return @"Unspecified";
            break;
        case kSecTrustResultRecoverableTrustFailure:
            return @"Recoverable Trust Failure";
            break;
        case kSecTrustResultFatalTrustFailure:
            return @"Fatal Trust Failure";
            break;
        case kSecTrustResultOtherError:
            return @"Other Error";
            break;
    }
    
    return @"Unknown";
}

@end
