//
//  CKCertificateChain.m
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

#import "CKCertificateChain.h"
#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>

@interface CKCertificateChain () <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream   * inputStream;
    NSOutputStream  * outputStream;

    void (^finishedBlock)(NSError *, CKCertificateChain *);
    NSString * queryDomain;
}

@property (strong, nonatomic, nonnull, readwrite) NSString * domain;
@property (strong, nonatomic, nonnull, readwrite) NSArray<CKCertificate *> * certificates;
@property (strong, nonatomic, nullable, readwrite) CKCertificate * rootCA;
@property (strong, nonatomic, nullable, readwrite) CKCertificate * intermediateCA;
@property (strong, nonatomic, nullable, readwrite) CKCertificate * server;
@property (nonatomic, readwrite) CKCertificateChainTrustStatus trusted;
@property (nonatomic, readwrite) CKCertificateChainCipher cipher;
@property (nonatomic, readwrite) BOOL crlVerified;

@end

@implementation CKCertificateChain

- (void) certificateChainFromURL:(NSURL *)URL finished:(void (^)(NSError * error, CKCertificateChain * chain))finished {
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
    SSLGetEnabledCiphers(context, ciphers, &numCiphers);

    [inputStream close];
    [outputStream close];

    BOOL isTrustedChain = trustStatus == kSecTrustResultUnspecified;

    CKCertificateChain * chain = [CKCertificateChain new];
    chain.certificates = certs;
    if (isTrustedChain) {
        chain.trusted = CKCertificateChainTrustStatusTrusted;
    } else {
        chain.trusted = CKCertificateChainTrustStatusUntrusted;
    }

    chain.cipher = ciphers[0];
    
    chain.domain = queryDomain;
    chain.server = [chain.certificates firstObject];
    if (certs.count > 1) {
        chain.rootCA = [chain.certificates lastObject];
        chain.intermediateCA = [chain.certificates objectAtIndex:1];

        if (chain.server.crlDistributionPoints.count > 0) {
            [chain.server.revoked
             isCertificateRevoked:chain.server
             rootCA:chain.intermediateCA
             finished:^(NSError * _Nullable error) {
                 finishedBlock(nil, chain);
             }];
            return;
        }
    }

    finishedBlock(nil, chain);
}

- (NSString *) cipherString {
    switch (self.cipher) {
        case CKCertificateChainCipher_SSL_NULL_WITH_NULL_NULL:
            return @"SSL_NULL_WITH_NULL_NULL";
        case CKCertificateChainCipher_SSL_RSA_WITH_NULL_MD5:
            return @"SSL_RSA_WITH_NULL_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_NULL_SHA:
            return @"SSL_RSA_WITH_NULL_SHA";
        case CKCertificateChainCipher_SSL_RSA_EXPORT_WITH_RC4_40_MD5:
            return @"SSL_RSA_EXPORT_WITH_RC4_40_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_RC4_128_MD5:
            return @"SSL_RSA_WITH_RC4_128_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_RC4_128_SHA:
            return @"SSL_RSA_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5:
            return @"SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_IDEA_CBC_SHA:
            return @"SSL_RSA_WITH_IDEA_CBC_SHA";
        case CKCertificateChainCipher_SSL_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case CKCertificateChainCipher_SSL_RSA_WITH_DES_CBC_SHA:
            return @"SSL_RSA_WITH_DES_CBC_SHA";
        case CKCertificateChainCipher_SSL_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"SSL_RSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_DSS_WITH_DES_CBC_SHA:
            return @"SSL_DH_DSS_WITH_DES_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_RSA_WITH_DES_CBC_SHA:
            return @"SSL_DH_RSA_WITH_DES_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA";
        case CKCertificateChainCipher_SSL_DHE_DSS_WITH_DES_CBC_SHA:
            return @"SSL_DHE_DSS_WITH_DES_CBC_SHA";
        case CKCertificateChainCipher_SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA";
        case CKCertificateChainCipher_SSL_DHE_RSA_WITH_DES_CBC_SHA:
            return @"SSL_DHE_RSA_WITH_DES_CBC_SHA";
        case CKCertificateChainCipher_SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_anon_EXPORT_WITH_RC4_40_MD5:
            return @"SSL_DH_anon_EXPORT_WITH_RC4_40_MD5";
        case CKCertificateChainCipher_SSL_DH_anon_WITH_RC4_128_MD5:
            return @"SSL_DH_anon_WITH_RC4_128_MD5";
        case CKCertificateChainCipher_SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_anon_WITH_DES_CBC_SHA:
            return @"SSL_DH_anon_WITH_DES_CBC_SHA";
        case CKCertificateChainCipher_SSL_DH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"SSL_DH_anon_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_SSL_FORTEZZA_DMS_WITH_NULL_SHA:
            return @"SSL_FORTEZZA_DMS_WITH_NULL_SHA";
        case CKCertificateChainCipher_SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA:
            return @"SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA";
        case CKCertificateChainCipher_TLS_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS_RSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_128_CBC_SHA:
            return @"TLS_DH_DSS_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS_DH_RSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_128_CBC_SHA:
            return @"TLS_DHE_DSS_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS_DHE_RSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_DH_anon_WITH_AES_128_CBC_SHA:
            return @"TLS_DH_anon_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS_RSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_256_CBC_SHA:
            return @"TLS_DH_DSS_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS_DH_RSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_256_CBC_SHA:
            return @"TLS_DHE_DSS_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS_DHE_RSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_DH_anon_WITH_AES_256_CBC_SHA:
            return @"TLS_DH_anon_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_NULL_SHA:
            return @"TLS_ECDH_ECDSA_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_RC4_128_SHA:
            return @"TLS_ECDH_ECDSA_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA:
            return @"TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA:
            return @"TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_NULL_SHA:
            return @"TLS_ECDHE_ECDSA_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_RC4_128_SHA:
            return @"TLS_ECDHE_ECDSA_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_NULL_SHA:
            return @"TLS_ECDH_RSA_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_RC4_128_SHA:
            return @"TLS_ECDH_RSA_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS_ECDH_RSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS_ECDH_RSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_NULL_SHA:
            return @"TLS_ECDHE_RSA_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_RC4_128_SHA:
            return @"TLS_ECDHE_RSA_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_anon_WITH_NULL_SHA:
            return @"TLS_ECDH_anon_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_ECDH_anon_WITH_RC4_128_SHA:
            return @"TLS_ECDH_anon_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_anon_WITH_AES_128_CBC_SHA:
            return @"TLS_ECDH_anon_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_ECDH_anon_WITH_AES_256_CBC_SHA:
            return @"TLS_ECDH_anon_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_RSA_WITH_NULL_SHA256:
            return @"TLS_RSA_WITH_NULL_SHA256";
        case CKCertificateChainCipher_TLS_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_RSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_RSA_WITH_AES_256_CBC_SHA256:
            return @"TLS_RSA_WITH_AES_256_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_128_CBC_SHA256:
            return @"TLS_DH_DSS_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_DH_RSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_128_CBC_SHA256:
            return @"TLS_DHE_DSS_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_DHE_RSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_256_CBC_SHA256:
            return @"TLS_DH_DSS_WITH_AES_256_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_256_CBC_SHA256:
            return @"TLS_DH_RSA_WITH_AES_256_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_256_CBC_SHA256:
            return @"TLS_DHE_DSS_WITH_AES_256_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_256_CBC_SHA256:
            return @"TLS_DHE_RSA_WITH_AES_256_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DH_anon_WITH_AES_128_CBC_SHA256:
            return @"TLS_DH_anon_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DH_anon_WITH_AES_256_CBC_SHA256:
            return @"TLS_DH_anon_WITH_AES_256_CBC_SHA256";
        case CKCertificateChainCipher_TLS_PSK_WITH_RC4_128_SHA:
            return @"TLS_PSK_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_PSK_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_PSK_WITH_AES_128_CBC_SHA:
            return @"TLS_PSK_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_PSK_WITH_AES_256_CBC_SHA:
            return @"TLS_PSK_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_RC4_128_SHA:
            return @"TLS_DHE_PSK_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_128_CBC_SHA:
            return @"TLS_DHE_PSK_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_256_CBC_SHA:
            return @"TLS_DHE_PSK_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_RC4_128_SHA:
            return @"TLS_RSA_PSK_WITH_RC4_128_SHA";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_128_CBC_SHA:
            return @"TLS_RSA_PSK_WITH_AES_128_CBC_SHA";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_256_CBC_SHA:
            return @"TLS_RSA_PSK_WITH_AES_256_CBC_SHA";
        case CKCertificateChainCipher_TLS_PSK_WITH_NULL_SHA:
            return @"TLS_PSK_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_NULL_SHA:
            return @"TLS_DHE_PSK_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_NULL_SHA:
            return @"TLS_RSA_PSK_WITH_NULL_SHA";
        case CKCertificateChainCipher_TLS_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_RSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_RSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_DHE_RSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_DHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_DHE_RSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_DH_RSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_DH_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_DH_RSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_128_GCM_SHA256:
            return @"TLS_DHE_DSS_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_DHE_DSS_WITH_AES_256_GCM_SHA384:
            return @"TLS_DHE_DSS_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_128_GCM_SHA256:
            return @"TLS_DH_DSS_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_DH_DSS_WITH_AES_256_GCM_SHA384:
            return @"TLS_DH_DSS_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_DH_anon_WITH_AES_128_GCM_SHA256:
            return @"TLS_DH_anon_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_DH_anon_WITH_AES_256_GCM_SHA384:
            return @"TLS_DH_anon_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_PSK_WITH_AES_128_GCM_SHA256:
            return @"TLS_PSK_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_PSK_WITH_AES_256_GCM_SHA384:
            return @"TLS_PSK_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_128_GCM_SHA256:
            return @"TLS_DHE_PSK_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_256_GCM_SHA384:
            return @"TLS_DHE_PSK_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_128_GCM_SHA256:
            return @"TLS_RSA_PSK_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_256_GCM_SHA384:
            return @"TLS_RSA_PSK_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_PSK_WITH_AES_128_CBC_SHA256:
            return @"TLS_PSK_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_PSK_WITH_AES_256_CBC_SHA384:
            return @"TLS_PSK_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_PSK_WITH_NULL_SHA256:
            return @"TLS_PSK_WITH_NULL_SHA256";
        case CKCertificateChainCipher_TLS_PSK_WITH_NULL_SHA384:
            return @"TLS_PSK_WITH_NULL_SHA384";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_128_CBC_SHA256:
            return @"TLS_DHE_PSK_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_AES_256_CBC_SHA384:
            return @"TLS_DHE_PSK_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_NULL_SHA256:
            return @"TLS_DHE_PSK_WITH_NULL_SHA256";
        case CKCertificateChainCipher_TLS_DHE_PSK_WITH_NULL_SHA384:
            return @"TLS_DHE_PSK_WITH_NULL_SHA384";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_128_CBC_SHA256:
            return @"TLS_RSA_PSK_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_AES_256_CBC_SHA384:
            return @"TLS_RSA_PSK_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_NULL_SHA256:
            return @"TLS_RSA_PSK_WITH_NULL_SHA256";
        case CKCertificateChainCipher_TLS_RSA_PSK_WITH_NULL_SHA384:
            return @"TLS_RSA_PSK_WITH_NULL_SHA384";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384:
            return @"TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256";
        case CKCertificateChainCipher_TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384";
        case CKCertificateChainCipher_TLS_EMPTY_RENEGOTIATION_INFO_SCSV:
            return @"TLS_EMPTY_RENEGOTIATION_INFO_SCSV";
        case CKCertificateChainCipher_SSL_RSA_WITH_RC2_CBC_MD5:
            return @"SSL_RSA_WITH_RC2_CBC_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_IDEA_CBC_MD5:
            return @"SSL_RSA_WITH_IDEA_CBC_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_DES_CBC_MD5:
            return @"SSL_RSA_WITH_DES_CBC_MD5";
        case CKCertificateChainCipher_SSL_RSA_WITH_3DES_EDE_CBC_MD5:
            return @"SSL_RSA_WITH_3DES_EDE_CBC_MD5";
        case CKCertificateChainCipher_SSL_NO_SUCH_CIPHERSUITE:
            return @"SSL_NO_SUCH_CIPHERSUITE";
    }
}

@end
