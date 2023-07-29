//
//  CKSecureTransportInspector.m
//
//  LGPLv3
//
//  Copyright (c) 2019 Ian Spence
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

#import "CKSecureTransportInspector.h"
#import "CKSecureTransportInspector+EnumValues.h"
#import "CKCertificate.h"
#import "CKCertificateChain.h"
#import "CKOCSPManager.h"
#import "CKCRLManager.h"
#import "CKSocketUtils.h"
#import "CKHTTPClient.h"
#import "CKInspectParameters+Private.h"
#import "CKHTTPServerInfo+Private.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <arpa/inet.h>
#include <mach/mach_time.h>

@interface CKSecureTransportInspector () <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    uint64_t startTime;
    void (^executeCompleted)(CKInspectResponse *, NSError *);
}

@property (strong, nonatomic) NSNumber * didCollectCertificates;
@property (strong, nonatomic) NSInputStream * inputStream;
@property (strong, nonatomic) NSOutputStream * outputStream;
@property (strong, nonatomic) CKInspectParameters * parameters;
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

@implementation CKSecureTransportInspector

- (void) executeWithParameters:(CKInspectParameters *)parameters completed:(void (^)(CKInspectResponse *, NSError *))completed {
    executeCompleted = completed;
    startTime = mach_absolute_time();
    PDebug(@"Getting certificate chain with SecureTransport %@:%d", parameters.ipAddress, parameters.port);

    self.parameters = parameters;
    self.didCollectCertificates = @NO;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)parameters.ipAddress, parameters.port, &readStream, &writeStream);

    self.outputStream = (__bridge NSOutputStream *)writeStream;
    self.inputStream = (__bridge NSInputStream *)readStream;

    self.inputStream.delegate = self;
    self.outputStream.delegate = self;

    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    NSDictionary *settings = @{
        (__bridge NSString *)kCFStreamSSLPeerName: parameters.hostAddress,
        (__bridge NSString *)kCFStreamSSLValidatesCertificateChain: (__bridge NSNumber *)kCFBooleanFalse,
    };
    CFReadStreamSetProperty((CFReadStreamRef)self.inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    CFWriteStreamSetProperty((CFWriteStreamRef)self.outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);

    PDebug(@"Opening stream");
    [self.outputStream open];
    [self.inputStream open];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:30.0]];
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    switch (event) {
        case NSStreamEventOpenCompleted: {
            PError(@"stream event NSStreamEventOpenCompleted");
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            PError(@"stream event NSStreamEventHasSpaceAvailable");
            [self streamHasSpaceAvailable:stream];
            self.didCollectCertificates = @YES;
            break;
        }

        case NSStreamEventHasBytesAvailable: {
            PError(@"stream event NSStreamEventHasBytesAvailable");
            break;
        }

        case NSStreamEventNone: {
            PError(@"stream event NSStreamEventNone");
            break;
        }

        case NSStreamEventErrorOccurred: {
            PError(@"NSStreamEventErrorOccurred occured: %@", stream.streamError.description);
            executeCompleted(nil, [stream streamError]);
            [self.inputStream close];
            [self.outputStream close];
            break;
        }

        case NSStreamEventEndEncountered: {
            PError(@"NSStreamEventEndEncountered occured: %@", stream.streamError.description);
            executeCompleted(nil, [stream streamError]);
            [self.inputStream close];
            [self.outputStream close];
            break;
        }

        default: {
            PError(@"Unknown stream event %lu", (unsigned long)event);
            break;
        }
    }
}

- (void) streamHasSpaceAvailable:(NSStream *)stream {
    // Because the HTTP request writes data, this event may be called multiple times.
    if (self.didCollectCertificates.boolValue) {
        return;
    }

    SecTrustRef trust = (__bridge SecTrustRef)[stream propertyForKey: (__bridge NSString *)kCFStreamPropertySSLPeerTrust];
    SecTrustResultType trustStatus;
    SecTrustGetTrustResult(trust, &trustStatus);
    if ([CKLogging sharedInstance].level == CKLoggingLevelDebug) {
        CFDictionaryRef trustResultDictionary = SecTrustCopyResult(trust);
        PDebug(@"Trust result details: %@", [(__bridge NSDictionary *)trustResultDictionary description]);
        CFRelease(trustResultDictionary);
    }

    long count = SecTrustGetCertificateCount(trust);
    if (count > CERTIFICATE_CHAIN_MAXIMUM) {
        PError(@"Server returned too many certificates. Count: %li, Max: %i", count, CERTIFICATE_CHAIN_MAXIMUM);
        executeCompleted(nil, MAKE_ERROR(-1, @"Too many certificates from server"));
        return;
    }

    NSMutableArray<CKCertificate *> * certs = [NSMutableArray arrayWithCapacity:count];

    for (long i = 0; i < count; i ++) {
        SecCertificateRef certificateRef = SecTrustGetCertificateAtIndex(trust, i);
        [certs setObject:[CKCertificate fromSecCertificateRef:certificateRef] atIndexedSubscript:i];
    }

    NSString * remoteAddr;
    if (IS_XCODE_TEST) {
        // For some reason we can't get the socket handle from a stream while running in a Xcode test.
        // Because the SecureTransport inspector is already ancient and legacy as-is, I'm not that
        // worried about not testing this specific part of the code
        remoteAddr = @"";
    } else {
        CFDataRef handleData = (CFDataRef)CFReadStreamCopyProperty(readStream, kCFStreamPropertySocketNativeHandle);
        if (handleData == nil) {
            PError(@"No native socket from stream");
            executeCompleted(nil, MAKE_ERROR(-1, @"No native socket from stream"));
            return;
        }
        long length = CFDataGetLength(handleData);
        uint8_t * buffer = malloc(length);
        CFDataGetBytes(handleData, CFRangeMake(0, length), buffer);
        int sock_fd = (int)*buffer;
        CFRelease(handleData);
        remoteAddr = [CKSocketUtils remoteAddressForSocket:sock_fd];
        free(buffer);
        if (remoteAddr == nil) {
            PError(@"No remote address from socket");
            executeCompleted(nil, MAKE_ERROR(-1, @"Unable to get remote address of peer"));
            return;
        }
    }

    SSLContextRef context = (SSLContextRef)CFReadStreamCopyProperty(readStream, kCFStreamPropertySSLContext);
    size_t numCiphers;
    SSLGetNumberEnabledCiphers(context, &numCiphers);
    SSLCipherSuite * ciphers = malloc(numCiphers);
    SSLGetNegotiatedCipher(context, ciphers);
    SSLProtocol protocol = 0;
    SSLGetNegotiatedProtocolVersion(context, &protocol);
    NSString * cipherString = [self CiphersuiteToString:ciphers[0]];
    NSString * protocolString = [self protocolString:protocol];
    CFRelease(context);
    free(ciphers);

    dispatch_queue_t httpQueue = dispatch_queue_create("com.ecnepsnai.CertificateKit.CKSecureTransportInspector.httpQueue", NULL);
    CKHTTPServerInfo * __block httpServerInfo;
    dispatch_block_t getHttpResponse = dispatch_block_create(0, ^{
        NSData * httpRequest = [CKHTTPClient requestForHost:self.parameters.hostAddress];
        [self.outputStream write:httpRequest.bytes maxLength:httpRequest.length];
        CKHTTPResponse * httpResponse = [CKHTTPClient responseFromStream:self.inputStream];
        if (httpResponse != nil) {
            httpServerInfo = [CKHTTPServerInfo fromHTTPResponse:httpResponse];
        }
    });
    dispatch_barrier_async(httpQueue, getHttpResponse);
    dispatch_block_wait(getHttpResponse, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));

    [self.inputStream close];
    [self.outputStream close];

    PDebug(@"Domain: '%@' trust result: '%@' (%d)", self.parameters.hostAddress, [self trustResultToString:trustStatus], trustStatus);

    self.chain = [CKCertificateChain new];
    self.chain.certificates = certs;

    self.chain.domain = self.parameters.hostAddress;

    if (certs.count == 0) {
        PError(@"No certificates presented by server");
        executeCompleted(nil, MAKE_ERROR(-1, @"No certificates presented by server."));
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
        [self.chain determineTrustFailureReason];
    }

    [self.chain checkAuthorityTrust];

    PDebug(@"Connected to '%@' (%@), Protocol version: %@, Ciphersuite: %@. Server returned %li certificates", self.parameters.hostAddress, remoteAddr, self.chain.protocol, self.chain.cipherSuite, count);

    self.chain.cipherSuite = cipherString;
    self.chain.protocol = protocolString;
    self.chain.remoteAddress = remoteAddr;
    if (certs.count > 1) {
        self.chain.rootCA = [self.chain.certificates lastObject];
        self.chain.intermediateCA = [self.chain.certificates objectAtIndex:1];
    }

    PDebug(@"Certificate chain: %@", [self.chain description]);
    PDebug(@"Finished getting certificate chain");
    executeCompleted([CKInspectResponse responseWithCertificateChain:self.chain httpServerInfo:httpServerInfo], nil);

    uint64_t endTime = mach_absolute_time();
    if (CKLogging.sharedInstance.level <= CKLoggingLevelDebug) {
        uint64_t elapsedTime = endTime - startTime;
        static double ticksToNanoseconds = 0.0;
        if (0.0 == ticksToNanoseconds) {
            mach_timebase_info_data_t timebase;
            mach_timebase_info(&timebase);
            ticksToNanoseconds = (double)timebase.numer / timebase.denom;
        }
        double elapsedTimeInNanoseconds = elapsedTime * ticksToNanoseconds;
        PDebug(@"SecureTransport getter collected certificate information in %fns", elapsedTimeInNanoseconds);
    }
}

- (CKRevoked *) getRevokedInformationForCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer {
    CKOCSPResponse * ocspResponse;
    CKCRLResponse * crlResponse;

    if (self.parameters.checkOCSP) {
        NSError * err = [[CKOCSPManager sharedManager] queryCertificate:certificate issuer:issuer response:&ocspResponse];
        if (err != nil) {
            PError(@"OCSP Error: %@", err.description);
        }
    }
    if (self.parameters.checkCRL) {
        NSError * err = [[CKCRLManager sharedManager] queryCertificate:certificate issuer:issuer response:&crlResponse];
        if (err != nil) {
            PError(@"CRL Error: %@", err.description);
        }
    }
    return [CKRevoked fromOCSPResponse:ocspResponse andCRLResponse:crlResponse];
}

@end
