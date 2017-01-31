//
//  CHCertificateFactory.m
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

#import "CHCertificateFactory.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>

@interface CHCertificateFactory() <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream   * inputStream;
    NSOutputStream  * outputStream;

    void (^finishedBlock)(NSError *, NSArray<CHCertificate *> *, BOOL);
}

@end

@implementation CHCertificateFactory

- (void) certificateChainFromURL:(NSURL *)URL finished:(void (^)(NSError * error,
                                                                 NSArray<CHCertificate *> * certificates,
                                                                 BOOL trustedChain))finished {
    finishedBlock = finished;

    unsigned int port = URL.port != nil ? [URL.port unsignedIntValue] : 443;
    NSLog(@"Fetching certificate chain from %@:%u", URL.host, port);
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)URL.host, port, &readStream, &writeStream);

    outputStream = (__bridge NSOutputStream *)writeStream;
    inputStream = (__bridge NSInputStream *)readStream;

    inputStream.delegate = self;
    outputStream.delegate = self;

    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    [outputStream open];
    [inputStream open];
    NSLog(@"Streams opened");
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
            NSLog(@"Streams closed due to error or EOF");
            finishedBlock([stream streamError], nil, NO);
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

    NSLog(@"Streams closed");
    [inputStream close];
    [outputStream close];

    NSLog(@"Processed %li certs", count);
    BOOL isTrustedChain = trustStatus == kSecTrustResultUnspecified;
    if (isTrustedChain) {
        NSLog(@"Certificate chain is trusted");
    } else {
        NSLog(@"Certificate chain is not trusted");
    }

    finishedBlock(nil, certs, isTrustedChain);
}

@end
