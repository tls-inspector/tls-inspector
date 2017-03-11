//
//  CHCertificateChain.m
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
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

#import "CHCertificateChain.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>

@interface CHCertificateChain () <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream   * inputStream;
    NSOutputStream  * outputStream;
    
    void (^finishedBlock)(NSError *, CHCertificateChain *);
    NSString * queryDomain;
}

@property (strong, nonatomic, nonnull, readwrite) NSString * domain;
@property (strong, nonatomic, nonnull, readwrite) NSArray<CHCertificate *> * certificates;
@property (strong, nonatomic, nullable, readwrite) CHCertificate * root;
@property (nonatomic, readwrite) BOOL trusted;

@end

@implementation CHCertificateChain

- (void) certificateChainFromURL:(NSURL *)URL finished:(void (^)(NSError * error, CHCertificateChain * chain))finished {
    finishedBlock = finished;
    queryDomain = URL.host;
    
    unsigned int port = URL.port != nil ? [URL.port unsignedIntValue] : 443;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)URL.host, port, &readStream, &writeStream);
    
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
            finishedBlock([stream streamError], nil);
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
    
    NSMutableArray<CHCertificate *> * certs = [NSMutableArray arrayWithCapacity:count];
    
    for (long i = 0; i < count; i ++) {
        SecCertificateRef certificateRef = SecTrustGetCertificateAtIndex(trust, i);
        NSData * certificateData = (NSData *)CFBridgingRelease(SecCertificateCopyData(certificateRef));
        const unsigned char * bytes = (const unsigned char *)[certificateData bytes];
        // This will leak
        X509 * cert = d2i_X509(NULL, &bytes, [certificateData length]);
        certificateData = nil;
        [certs setObject:[CHCertificate fromX509:cert] atIndexedSubscript:i];
    }
    
    [inputStream close];
    [outputStream close];
    
    BOOL isTrustedChain = trustStatus == kSecTrustResultUnspecified;
    
    CHCertificateChain * chain = [CHCertificateChain new];
    chain.certificates = certs;
    chain.trusted = isTrustedChain;
    chain.domain = queryDomain;
    if (certs.count > 1) {
        chain.root = [chain.certificates lastObject];
    }

    finishedBlock(nil, chain);
}

@end
