//
//  CKSecureTransportCertificateChainGetter.m
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

#import "CKSecureTransportCertificateChainGetter.h"
#import "CKCertificate.h"
#import "CKCertificateChain.h"
#import "CKOCSPManager.h"
#import "CKCRLManager.h"
#import "CKSocketUtils.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <arpa/inet.h>
#include <mach/mach_time.h>

@interface CKSecureTransportCertificateChainGetter () <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream   * inputStream;
    NSOutputStream  * outputStream;
    uint64_t startTime;
}

@property (strong, nonatomic) CKGetterParameters * parameters;
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

@implementation CKSecureTransportCertificateChainGetter

- (void) performTaskWithParameters:(CKGetterParameters *)parameters {
    startTime = mach_absolute_time();
    PDebug(@"Getting certificate chain with SecureTransport");

    self.parameters = parameters;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)parameters.ipAddress, parameters.port, &readStream, &writeStream);

    outputStream = (__bridge NSOutputStream *)writeStream;
    inputStream = (__bridge NSInputStream *)readStream;

    inputStream.delegate = self;
    outputStream.delegate = self;

    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    NSDictionary *settings = @{
        (__bridge NSString *)kCFStreamSSLPeerName: parameters.hostAddress,
        (__bridge NSString *)kCFStreamSSLValidatesCertificateChain: (__bridge NSNumber *)kCFBooleanFalse,
    };
    CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    
    [outputStream open];
    [inputStream open];
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    switch (event) {
        case NSStreamEventOpenCompleted: {
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
            self.finished = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
                [self.delegate getter:self failedTaskWithError:[stream streamError]];
            }
            [inputStream close];
            [outputStream close];
            break;
        }
    }
}

- (void) streamHasSpaceAvailable:(NSStream *)stream {
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
        self.finished = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
            [self.delegate getter:self failedTaskWithError:MAKE_ERROR(-1, @"Too many certificates from server")];
        }
        return;
    }

    NSMutableArray<CKCertificate *> * certs = [NSMutableArray arrayWithCapacity:count];

    for (long i = 0; i < count; i ++) {
        SecCertificateRef certificateRef = SecTrustGetCertificateAtIndex(trust, i);
        [certs setObject:[CKCertificate fromSecCertificateRef:certificateRef] atIndexedSubscript:i];
    }

    self.chain.trustedByMozilla = [CKRootCACertificateBundle.sharedInstance.mozillaBundle validateCertificates:certs];

    CFDataRef handleData = (CFDataRef)CFReadStreamCopyProperty((__bridge CFReadStreamRef) inputStream, kCFStreamPropertySocketNativeHandle);
    long length = CFDataGetLength(handleData);
    uint8_t * buffer = malloc(length);
    CFDataGetBytes(handleData, CFRangeMake(0, length), buffer);
    int sock_fd = (int)*buffer;
    NSString * remoteAddr = [CKSocketUtils remoteAddressForSocket:sock_fd];
    free(buffer);
    if (remoteAddr == nil) {
        PError(@"No remote address from socket");
        self.finished = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
            [self.delegate getter:self failedTaskWithError:MAKE_ERROR(-1, @"Unable to get remote address of peer")];
        }
        return;
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

    PDebug(@"Domain: '%@' trust result: '%@' (%d)", self.parameters.hostAddress, [self trustResultToString:trustStatus], trustStatus);

    self.chain = [CKCertificateChain new];
    self.chain.certificates = certs;

    self.chain.domain = self.parameters.hostAddress;

    if (certs.count == 0) {
        PError(@"No certificates presented by server");
        self.finished = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
            [self.delegate getter:self failedTaskWithError:MAKE_ERROR(-1, @"No certificates presented by server.")];
        }
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

    self.chain.cipherSuite = [self CiphersuiteToString:ciphers[0]];
    self.chain.protocol = [self protocolString:protocol];
    self.chain.remoteAddress = remoteAddr;
    if (certs.count > 1) {
        self.chain.rootCA = [self.chain.certificates lastObject];
        self.chain.intermediateCA = [self.chain.certificates objectAtIndex:1];
    }

    PDebug(@"Certificate chain: %@", [self.chain description]);
    PDebug(@"Finished getting certificate chain");
    self.finished = YES;
    self.successful = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(getter:finishedTaskWithResult:)]) {
        [self.delegate getter:self finishedTaskWithResult:self.chain];
    }

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
    NSError * ocspError;
    NSError * crlError;

    if (self.parameters.checkOCSP) {
        [[CKOCSPManager sharedManager] queryCertificate:certificate issuer:issuer response:&ocspResponse error:&ocspError];
        if (ocspError != nil) {
            PError(@"OCSP Error: %@", ocspError.description);
        }
    }
    if (self.parameters.checkCRL) {
        [[CKCRLManager sharedManager] queryCertificate:certificate issuer:issuer response:&crlResponse error:&crlError];
        if (crlError != nil) {
            PError(@"CRL Error: %@", crlError.description);
        }
    }
    return [CKRevoked fromOCSPResponse:ocspResponse andCRLResponse:crlResponse];
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

- (NSString *) CiphersuiteToString:(SSLCipherSuite)cipher {
    switch (cipher) {
        case SSL_NULL_WITH_NULL_NULL:
            return @"NULL_WITH_NULL_NULL";
        case SSL_RSA_WITH_NULL_MD5:
            return @"RSA_WITH_NULL_MD5";
        case SSL_RSA_WITH_NULL_SHA:
            return @"RSA_WITH_NULL_SHA";
        case SSL_RSA_EXPORT_WITH_RC4_40_MD5:
            return @"RSA_EXPORT_WITH_RC4_40_MD5";
        case SSL_RSA_WITH_RC4_128_MD5:
            return @"RSA_WITH_RC4_128_MD5";
        case SSL_RSA_WITH_RC4_128_SHA:
            return @"RSA_WITH_RC4_128_SHA";
        case SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5:
            return @"RSA_EXPORT_WITH_RC2_CBC_40_MD5";
        case SSL_RSA_WITH_IDEA_CBC_SHA:
            return @"RSA_WITH_IDEA_CBC_SHA";
        case SSL_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_RSA_WITH_DES_CBC_SHA:
            return @"RSA_WITH_DES_CBC_SHA";
        case SSL_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_DSS_WITH_DES_CBC_SHA:
            return @"DH_DSS_WITH_DES_CBC_SHA";
        case SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"DH_DSS_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_RSA_WITH_DES_CBC_SHA:
            return @"DH_RSA_WITH_DES_CBC_SHA";
        case SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"DH_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"DHE_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DHE_DSS_WITH_DES_CBC_SHA:
            return @"DHE_DSS_WITH_DES_CBC_SHA";
        case SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"DHE_DSS_WITH_3DES_EDE_CBC_SHA";
        case SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"DHE_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DHE_RSA_WITH_DES_CBC_SHA:
            return @"DHE_RSA_WITH_DES_CBC_SHA";
        case SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"DHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case SSL_DH_anon_EXPORT_WITH_RC4_40_MD5:
            return @"DH_anon_EXPORT_WITH_RC4_40_MD5";
        case SSL_DH_anon_WITH_RC4_128_MD5:
            return @"DH_anon_WITH_RC4_128_MD5";
        case SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA:
            return @"DH_anon_EXPORT_WITH_DES40_CBC_SHA";
        case SSL_DH_anon_WITH_DES_CBC_SHA:
            return @"DH_anon_WITH_DES_CBC_SHA";
        case SSL_DH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"DH_anon_WITH_3DES_EDE_CBC_SHA";
        case SSL_FORTEZZA_DMS_WITH_NULL_SHA:
            return @"FORTEZZA_DMS_WITH_NULL_SHA";
        case SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA:
            return @"FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA";
        case TLS_RSA_WITH_AES_128_CBC_SHA:
            return @"RSA_WITH_AES_128_CBC_SHA";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA:
            return @"DH_DSS_WITH_AES_128_CBC_SHA";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA:
            return @"DH_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA:
            return @"DHE_DSS_WITH_AES_128_CBC_SHA";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA:
            return @"DHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA:
            return @"DH_anon_WITH_AES_128_CBC_SHA";
        case TLS_RSA_WITH_AES_256_CBC_SHA:
            return @"RSA_WITH_AES_256_CBC_SHA";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA:
            return @"DH_DSS_WITH_AES_256_CBC_SHA";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA:
            return @"DH_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA:
            return @"DHE_DSS_WITH_AES_256_CBC_SHA";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA:
            return @"DHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA:
            return @"DH_anon_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_NULL_SHA:
            return @"ECDH_ECDSA_WITH_NULL_SHA";
        case TLS_ECDH_ECDSA_WITH_RC4_128_SHA:
            return @"ECDH_ECDSA_WITH_RC4_128_SHA";
        case TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDH_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDH_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_NULL_SHA:
            return @"ECDHE_ECDSA_WITH_NULL_SHA";
        case TLS_ECDHE_ECDSA_WITH_RC4_128_SHA:
            return @"ECDHE_ECDSA_WITH_RC4_128_SHA";
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_RSA_WITH_NULL_SHA:
            return @"ECDH_RSA_WITH_NULL_SHA";
        case TLS_ECDH_RSA_WITH_RC4_128_SHA:
            return @"ECDH_RSA_WITH_RC4_128_SHA";
        case TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDH_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDH_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_NULL_SHA:
            return @"ECDHE_RSA_WITH_NULL_SHA";
        case TLS_ECDHE_RSA_WITH_RC4_128_SHA:
            return @"ECDHE_RSA_WITH_RC4_128_SHA";
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA";
        case TLS_ECDH_anon_WITH_NULL_SHA:
            return @"ECDH_anon_WITH_NULL_SHA";
        case TLS_ECDH_anon_WITH_RC4_128_SHA:
            return @"ECDH_anon_WITH_RC4_128_SHA";
        case TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"ECDH_anon_WITH_3DES_EDE_CBC_SHA";
        case TLS_ECDH_anon_WITH_AES_128_CBC_SHA:
            return @"ECDH_anon_WITH_AES_128_CBC_SHA";
        case TLS_ECDH_anon_WITH_AES_256_CBC_SHA:
            return @"ECDH_anon_WITH_AES_256_CBC_SHA";
        case TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA:
            return @"ECDHE_PSK_WITH_AES_128_CBC_SHA";
        case TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA:
            return @"ECDHE_PSK_WITH_AES_256_CBC_SHA";
        case TLS_PSK_WITH_CHACHA20_POLY1305_SHA256:
            return @"PSK_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_RSA_WITH_NULL_SHA256:
            return @"RSA_WITH_NULL_SHA256";
        case TLS_RSA_WITH_AES_128_CBC_SHA256:
            return @"RSA_WITH_AES_128_CBC_SHA256";
        case TLS_RSA_WITH_AES_256_CBC_SHA256:
            return @"RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA256:
            return @"DH_DSS_WITH_AES_128_CBC_SHA256";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA256:
            return @"DH_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA256:
            return @"DHE_DSS_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"DHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA256:
            return @"DH_DSS_WITH_AES_256_CBC_SHA256";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA256:
            return @"DH_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA256:
            return @"DHE_DSS_WITH_AES_256_CBC_SHA256";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA256:
            return @"DHE_RSA_WITH_AES_256_CBC_SHA256";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA256:
            return @"DH_anon_WITH_AES_128_CBC_SHA256";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA256:
            return @"DH_anon_WITH_AES_256_CBC_SHA256";
        case TLS_PSK_WITH_RC4_128_SHA:
            return @"PSK_WITH_RC4_128_SHA";
        case TLS_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"PSK_WITH_3DES_EDE_CBC_SHA";
        case TLS_PSK_WITH_AES_128_CBC_SHA:
            return @"PSK_WITH_AES_128_CBC_SHA";
        case TLS_PSK_WITH_AES_256_CBC_SHA:
            return @"PSK_WITH_AES_256_CBC_SHA";
        case TLS_DHE_PSK_WITH_RC4_128_SHA:
            return @"DHE_PSK_WITH_RC4_128_SHA";
        case TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"DHE_PSK_WITH_3DES_EDE_CBC_SHA";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA:
            return @"DHE_PSK_WITH_AES_128_CBC_SHA";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA:
            return @"DHE_PSK_WITH_AES_256_CBC_SHA";
        case TLS_RSA_PSK_WITH_RC4_128_SHA:
            return @"RSA_PSK_WITH_RC4_128_SHA";
        case TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"RSA_PSK_WITH_3DES_EDE_CBC_SHA";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA:
            return @"RSA_PSK_WITH_AES_128_CBC_SHA";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA:
            return @"RSA_PSK_WITH_AES_256_CBC_SHA";
        case TLS_PSK_WITH_NULL_SHA:
            return @"PSK_WITH_NULL_SHA";
        case TLS_DHE_PSK_WITH_NULL_SHA:
            return @"DHE_PSK_WITH_NULL_SHA";
        case TLS_RSA_PSK_WITH_NULL_SHA:
            return @"RSA_PSK_WITH_NULL_SHA";
        case TLS_RSA_WITH_AES_128_GCM_SHA256:
            return @"RSA_WITH_AES_128_GCM_SHA256";
        case TLS_RSA_WITH_AES_256_GCM_SHA384:
            return @"RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"DHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"DHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DH_RSA_WITH_AES_128_GCM_SHA256:
            return @"DH_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_DH_RSA_WITH_AES_256_GCM_SHA384:
            return @"DH_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_DSS_WITH_AES_128_GCM_SHA256:
            return @"DHE_DSS_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_DSS_WITH_AES_256_GCM_SHA384:
            return @"DHE_DSS_WITH_AES_256_GCM_SHA384";
        case TLS_DH_DSS_WITH_AES_128_GCM_SHA256:
            return @"DH_DSS_WITH_AES_128_GCM_SHA256";
        case TLS_DH_DSS_WITH_AES_256_GCM_SHA384:
            return @"DH_DSS_WITH_AES_256_GCM_SHA384";
        case TLS_DH_anon_WITH_AES_128_GCM_SHA256:
            return @"DH_anon_WITH_AES_128_GCM_SHA256";
        case TLS_DH_anon_WITH_AES_256_GCM_SHA384:
            return @"DH_anon_WITH_AES_256_GCM_SHA384";
        case TLS_PSK_WITH_AES_128_GCM_SHA256:
            return @"PSK_WITH_AES_128_GCM_SHA256";
        case TLS_PSK_WITH_AES_256_GCM_SHA384:
            return @"PSK_WITH_AES_256_GCM_SHA384";
        case TLS_DHE_PSK_WITH_AES_128_GCM_SHA256:
            return @"DHE_PSK_WITH_AES_128_GCM_SHA256";
        case TLS_DHE_PSK_WITH_AES_256_GCM_SHA384:
            return @"DHE_PSK_WITH_AES_256_GCM_SHA384";
        case TLS_RSA_PSK_WITH_AES_128_GCM_SHA256:
            return @"RSA_PSK_WITH_AES_128_GCM_SHA256";
        case TLS_RSA_PSK_WITH_AES_256_GCM_SHA384:
            return @"RSA_PSK_WITH_AES_256_GCM_SHA384";
        case TLS_PSK_WITH_AES_128_CBC_SHA256:
            return @"PSK_WITH_AES_128_CBC_SHA256";
        case TLS_PSK_WITH_AES_256_CBC_SHA384:
            return @"PSK_WITH_AES_256_CBC_SHA384";
        case TLS_PSK_WITH_NULL_SHA256:
            return @"PSK_WITH_NULL_SHA256";
        case TLS_PSK_WITH_NULL_SHA384:
            return @"PSK_WITH_NULL_SHA384";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA256:
            return @"DHE_PSK_WITH_AES_128_CBC_SHA256";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA384:
            return @"DHE_PSK_WITH_AES_256_CBC_SHA384";
        case TLS_DHE_PSK_WITH_NULL_SHA256:
            return @"DHE_PSK_WITH_NULL_SHA256";
        case TLS_DHE_PSK_WITH_NULL_SHA384:
            return @"DHE_PSK_WITH_NULL_SHA384";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA256:
            return @"RSA_PSK_WITH_AES_128_CBC_SHA256";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA384:
            return @"RSA_PSK_WITH_AES_256_CBC_SHA384";
        case TLS_RSA_PSK_WITH_NULL_SHA256:
            return @"RSA_PSK_WITH_NULL_SHA256";
        case TLS_RSA_PSK_WITH_NULL_SHA384:
            return @"RSA_PSK_WITH_NULL_SHA384";
        case TLS_AES_128_GCM_SHA256:
            return @"AES_128_GCM_SHA256";
        case TLS_AES_256_GCM_SHA384:
            return @"AES_256_GCM_SHA384";
        case TLS_CHACHA20_POLY1305_SHA256:
            return @"CHACHA20_POLY1305_SHA256";
        case TLS_AES_128_CCM_SHA256:
            return @"AES_128_CCM_SHA256";
        case TLS_AES_128_CCM_8_SHA256:
            return @"AES_128_CCM_8_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"ECDH_ECDSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"ECDH_ECDSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256:
            return @"ECDH_RSA_WITH_AES_128_CBC_SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384:
            return @"ECDH_RSA_WITH_AES_256_CBC_SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"ECDH_ECDSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"ECDH_ECDSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDHE_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDHE_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256:
            return @"ECDH_RSA_WITH_AES_128_GCM_SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384:
            return @"ECDH_RSA_WITH_AES_256_GCM_SHA384";
        case TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:
            return @"ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256";
        case TLS_EMPTY_RENEGOTIATION_INFO_SCSV:
            return @"EMPTY_RENEGOTIATION_INFO_SCSV";
        case SSL_RSA_WITH_RC2_CBC_MD5:
            return @"RSA_WITH_RC2_CBC_MD5";
        case SSL_RSA_WITH_IDEA_CBC_MD5:
            return @"RSA_WITH_IDEA_CBC_MD5";
        case SSL_RSA_WITH_DES_CBC_MD5:
            return @"RSA_WITH_DES_CBC_MD5";
        case SSL_RSA_WITH_3DES_EDE_CBC_MD5:
            return @"RSA_WITH_3DES_EDE_CBC_MD5";
        case SSL_NO_SUCH_CIPHERSUITE:
            return @"NO_SUCH_CIPHERSUITE";
    }

    return @"Unknown";
}

- (NSString *) protocolString:(int)protocol {
    switch (protocol) {
        case kSSLProtocol3:
            return @"SSLv3";
        case kTLSProtocol1:
            return @"TLS 1.0";
        case kTLSProtocol11:
            return @"TLS 1.1";
        case kTLSProtocol12:
            return @"TLS 1.2";
        case kTLSProtocol13:
            return @"TLS 1.3";
        case kDTLSProtocol1:
            return @"DTLS 1";
        case kSSLProtocol2:
            return @"SSLv2";
    }

    return @"Unknown";
}

@end
