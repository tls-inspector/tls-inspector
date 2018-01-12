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

    BOOL isTrustedChain = trustStatus == kSecTrustResultUnspecified;

    self.chain = [CKCertificateChain new];
    self.chain.certificates = certs;
    if (isTrustedChain) {
        self.chain.trusted = CKCertificateChainTrustStatusTrusted;
    } else {
        // Apple does not provide (as far as I am aware) detailed information as to why a certificate chain
        // failed evalulation. Therefor we have to made some deductions based off of information we do know.
        // These are:
        // - If the any cert in the chain is expired or not yet valid
        // - If the chain has less than 3 certificates, consider it self signed (risky)
        // Otherwise, fall back to a generic reason
        if (self.chain.certificates.count < 3) {
            self.chain.trusted = CKCertificateChainTrustStatusSelfSigned;
        } else {
            self.chain.trusted = CKCertificateChainTrustStatusUntrusted;
        }
        for (CKCertificate * cert in self.chain.certificates) {
            if (!cert.validIssueDate) {
                self.chain.trusted = CKCertificateChainTrustStatusInvalidDate;
            }
        }
    }

    self.chain.cipher = ciphers[0];
    self.chain.protocol = protocol;

    self.chain.domain = queryURL.host;
    self.chain.server = [self.chain.certificates firstObject];
    if (certs.count > 1) {
        self.chain.rootCA = [self.chain.certificates lastObject];
        self.chain.intermediateCA = [self.chain.certificates objectAtIndex:1];

        if (self.chain.server.crlDistributionPoints.count > 0) {
            [self.chain.server.revoked
             isCertificateRevoked:self.chain.server
             intermediateCA:self.chain.intermediateCA
             finished:^(NSError * _Nullable error) {
                 if (!error) {
                     if (self.chain.server.revoked.isRevoked) {
                         self.chain.trusted = CKCertificateChainTrustStatusRevoked;
                     }
                 }
                 [self.delegate getter:self finishedTaskWithResult:self.chain];
                 self.finished = YES;
             }];
            return;
        }
    }

    [self.delegate getter:self finishedTaskWithResult:self.chain];
    self.finished = YES;
}

@end
