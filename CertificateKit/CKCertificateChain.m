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
@property (nonatomic, readwrite) SSLCipherSuite cipher;
@property (nonatomic, readwrite) SSLProtocol protocol;
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
    SSLGetNegotiatedCipher(context, ciphers);
    
    SSLProtocol protocol = 0;
    SSLGetNegotiatedProtocolVersion(context, &protocol);

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
    chain.protocol = protocol;

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
        case SSL_NULL_WITH_NULL_NULL:
            return @"SSL NULL with NULL NULL";
        case SSL_RSA_WITH_NULL_MD5:
            return @"SSL RSA with NULL MD5";
        case SSL_RSA_WITH_NULL_SHA:
            return @"SSL RSA with NULL SHA";
        case SSL_RSA_EXPORT_WITH_RC4_40_MD5:
            return @"SSL RSA EXPORT with RC4 40 MD5";
        case SSL_RSA_WITH_RC4_128_MD5:
            return @"SSL RSA with RC4 128 MD5";
        case SSL_RSA_WITH_RC4_128_SHA:
            return @"SSL RSA with RC4 128 SHA";
        case SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5:
            return @"SSL RSA EXPORT with RC2 CBC 40 MD5";
        case SSL_RSA_WITH_IDEA_CBC_SHA:
            return @"SSL RSA with IDEA CBC SHA";
        case SSL_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL RSA EXPORT with DES40 CBC SHA";
        case SSL_RSA_WITH_DES_CBC_SHA:
            return @"SSL RSA with DES CBC SHA";
        case SSL_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"SSL RSA with 3DES EDE CBC SHA";
        case SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL DH DSS EXPORT with DES40 CBC SHA";
        case SSL_DH_DSS_WITH_DES_CBC_SHA:
            return @"SSL DH DSS with DES CBC SHA";
        case SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"SSL DH DSS with 3DES EDE CBC SHA";
        case SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL DH RSA EXPORT with DES40 CBC SHA";
        case SSL_DH_RSA_WITH_DES_CBC_SHA:
            return @"SSL DH RSA with DES CBC SHA";
        case SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"SSL DH RSA with 3DES EDE CBC SHA";
        case SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL DHE DSS EXPORT with DES40 CBC SHA";
        case SSL_DHE_DSS_WITH_DES_CBC_SHA:
            return @"SSL DHE DSS with DES CBC SHA";
        case SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA:
            return @"SSL DHE DSS with 3DES EDE CBC SHA";
        case SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL DHE RSA EXPORT with DES40 CBC SHA";
        case SSL_DHE_RSA_WITH_DES_CBC_SHA:
            return @"SSL DHE RSA with DES CBC SHA";
        case SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"SSL DHE RSA with 3DES EDE CBC SHA";
        case SSL_DH_anon_EXPORT_WITH_RC4_40_MD5:
            return @"SSL DH anon EXPORT with RC4 40 MD5";
        case SSL_DH_anon_WITH_RC4_128_MD5:
            return @"SSL DH anon with RC4 128 MD5";
        case SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA:
            return @"SSL DH anon EXPORT with DES40 CBC SHA";
        case SSL_DH_anon_WITH_DES_CBC_SHA:
            return @"SSL DH anon with DES CBC SHA";
        case SSL_DH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"SSL DH anon with 3DES EDE CBC SHA";
        case SSL_FORTEZZA_DMS_WITH_NULL_SHA:
            return @"SSL FORTEZZA DMS with NULL SHA";
        case SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA:
            return @"SSL FORTEZZA DMS with FORTEZZA CBC SHA";
        case TLS_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS RSA with AES 128 CBC SHA";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA:
            return @"TLS DH DSS with AES 128 CBC SHA";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS DH RSA with AES 128 CBC SHA";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA:
            return @"TLS DHE DSS with AES 128 CBC SHA";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS DHE RSA with AES 128 CBC SHA";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA:
            return @"TLS DH anon with AES 128 CBC SHA";
        case TLS_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS RSA with AES 256 CBC SHA";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA:
            return @"TLS DH DSS with AES 256 CBC SHA";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS DH RSA with AES 256 CBC SHA";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA:
            return @"TLS DHE DSS with AES 256 CBC SHA";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS DHE RSA with AES 256 CBC SHA";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA:
            return @"TLS DH anon with AES 256 CBC SHA";
        case TLS_ECDH_ECDSA_WITH_NULL_SHA:
            return @"TLS ECDH ECDSA with NULL SHA";
        case TLS_ECDH_ECDSA_WITH_RC4_128_SHA:
            return @"TLS ECDH ECDSA with RC4 128 SHA";
        case TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS ECDH ECDSA with 3DES EDE CBC SHA";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA:
            return @"TLS ECDH ECDSA with AES 128 CBC SHA";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA:
            return @"TLS ECDH ECDSA with AES 256 CBC SHA";
        case TLS_ECDHE_ECDSA_WITH_NULL_SHA:
            return @"TLS ECDHE ECDSA with NULL SHA";
        case TLS_ECDHE_ECDSA_WITH_RC4_128_SHA:
            return @"TLS ECDHE ECDSA with RC4 128 SHA";
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS ECDHE ECDSA with 3DES EDE CBC SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return @"TLS ECDHE ECDSA with AES 128 CBC SHA";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return @"TLS ECDHE ECDSA with AES 256 CBC SHA";
        case TLS_ECDH_RSA_WITH_NULL_SHA:
            return @"TLS ECDH RSA with NULL SHA";
        case TLS_ECDH_RSA_WITH_RC4_128_SHA:
            return @"TLS ECDH RSA with RC4 128 SHA";
        case TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS ECDH RSA with 3DES EDE CBC SHA";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS ECDH RSA with AES 128 CBC SHA";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS ECDH RSA with AES 256 CBC SHA";
        case TLS_ECDHE_RSA_WITH_NULL_SHA:
            return @"TLS ECDHE RSA with NULL SHA";
        case TLS_ECDHE_RSA_WITH_RC4_128_SHA:
            return @"TLS ECDHE RSA with RC4 128 SHA";
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return @"TLS ECDHE RSA with 3DES EDE CBC SHA";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return @"TLS ECDHE RSA with AES 128 CBC SHA";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return @"TLS ECDHE RSA with AES 256 CBC SHA";
        case TLS_ECDH_anon_WITH_NULL_SHA:
            return @"TLS ECDH anon with NULL SHA";
        case TLS_ECDH_anon_WITH_RC4_128_SHA:
            return @"TLS ECDH anon with RC4 128 SHA";
        case TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA:
            return @"TLS ECDH anon with 3DES EDE CBC SHA";
        case TLS_ECDH_anon_WITH_AES_128_CBC_SHA:
            return @"TLS ECDH anon with AES 128 CBC SHA";
        case TLS_ECDH_anon_WITH_AES_256_CBC_SHA:
            return @"TLS ECDH anon with AES 256 CBC SHA";
        case TLS_RSA_WITH_NULL_SHA256:
            return @"TLS RSA with NULL SHA256";
        case TLS_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS RSA with AES 128 CBC SHA256";
        case TLS_RSA_WITH_AES_256_CBC_SHA256:
            return @"TLS RSA with AES 256 CBC SHA256";
        case TLS_DH_DSS_WITH_AES_128_CBC_SHA256:
            return @"TLS DH DSS with AES 128 CBC SHA256";
        case TLS_DH_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS DH RSA with AES 128 CBC SHA256";
        case TLS_DHE_DSS_WITH_AES_128_CBC_SHA256:
            return @"TLS DHE DSS with AES 128 CBC SHA256";
        case TLS_DHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS DHE RSA with AES 128 CBC SHA256";
        case TLS_DH_DSS_WITH_AES_256_CBC_SHA256:
            return @"TLS DH DSS with AES 256 CBC SHA256";
        case TLS_DH_RSA_WITH_AES_256_CBC_SHA256:
            return @"TLS DH RSA with AES 256 CBC SHA256";
        case TLS_DHE_DSS_WITH_AES_256_CBC_SHA256:
            return @"TLS DHE DSS with AES 256 CBC SHA256";
        case TLS_DHE_RSA_WITH_AES_256_CBC_SHA256:
            return @"TLS DHE RSA with AES 256 CBC SHA256";
        case TLS_DH_anon_WITH_AES_128_CBC_SHA256:
            return @"TLS DH anon with AES 128 CBC SHA256";
        case TLS_DH_anon_WITH_AES_256_CBC_SHA256:
            return @"TLS DH anon with AES 256 CBC SHA256";
        case TLS_PSK_WITH_RC4_128_SHA:
            return @"TLS PSK with RC4 128 SHA";
        case TLS_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"TLS PSK with 3DES EDE CBC SHA";
        case TLS_PSK_WITH_AES_128_CBC_SHA:
            return @"TLS PSK with AES 128 CBC SHA";
        case TLS_PSK_WITH_AES_256_CBC_SHA:
            return @"TLS PSK with AES 256 CBC SHA";
        case TLS_DHE_PSK_WITH_RC4_128_SHA:
            return @"TLS DHE PSK with RC4 128 SHA";
        case TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"TLS DHE PSK with 3DES EDE CBC SHA";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA:
            return @"TLS DHE PSK with AES 128 CBC SHA";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA:
            return @"TLS DHE PSK with AES 256 CBC SHA";
        case TLS_RSA_PSK_WITH_RC4_128_SHA:
            return @"TLS RSA PSK with RC4 128 SHA";
        case TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA:
            return @"TLS RSA PSK with 3DES EDE CBC SHA";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA:
            return @"TLS RSA PSK with AES 128 CBC SHA";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA:
            return @"TLS RSA PSK with AES 256 CBC SHA";
        case TLS_PSK_WITH_NULL_SHA:
            return @"TLS PSK with NULL SHA";
        case TLS_DHE_PSK_WITH_NULL_SHA:
            return @"TLS DHE PSK with NULL SHA";
        case TLS_RSA_PSK_WITH_NULL_SHA:
            return @"TLS RSA PSK with NULL SHA";
        case TLS_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS RSA with AES 128 GCM SHA256";
        case TLS_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS RSA with AES 256 GCM SHA384";
        case TLS_DHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS DHE RSA with AES 128 GCM SHA256";
        case TLS_DHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS DHE RSA with AES 256 GCM SHA384";
        case TLS_DH_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS DH RSA with AES 128 GCM SHA256";
        case TLS_DH_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS DH RSA with AES 256 GCM SHA384";
        case TLS_DHE_DSS_WITH_AES_128_GCM_SHA256:
            return @"TLS DHE DSS with AES 128 GCM SHA256";
        case TLS_DHE_DSS_WITH_AES_256_GCM_SHA384:
            return @"TLS DHE DSS with AES 256 GCM SHA384";
        case TLS_DH_DSS_WITH_AES_128_GCM_SHA256:
            return @"TLS DH DSS with AES 128 GCM SHA256";
        case TLS_DH_DSS_WITH_AES_256_GCM_SHA384:
            return @"TLS DH DSS with AES 256 GCM SHA384";
        case TLS_DH_anon_WITH_AES_128_GCM_SHA256:
            return @"TLS DH anon with AES 128 GCM SHA256";
        case TLS_DH_anon_WITH_AES_256_GCM_SHA384:
            return @"TLS DH anon with AES 256 GCM SHA384";
        case TLS_PSK_WITH_AES_128_GCM_SHA256:
            return @"TLS PSK with AES 128 GCM SHA256";
        case TLS_PSK_WITH_AES_256_GCM_SHA384:
            return @"TLS PSK with AES 256 GCM SHA384";
        case TLS_DHE_PSK_WITH_AES_128_GCM_SHA256:
            return @"TLS DHE PSK with AES 128 GCM SHA256";
        case TLS_DHE_PSK_WITH_AES_256_GCM_SHA384:
            return @"TLS DHE PSK with AES 256 GCM SHA384";
        case TLS_RSA_PSK_WITH_AES_128_GCM_SHA256:
            return @"TLS RSA PSK with AES 128 GCM SHA256";
        case TLS_RSA_PSK_WITH_AES_256_GCM_SHA384:
            return @"TLS RSA PSK with AES 256 GCM SHA384";
        case TLS_PSK_WITH_AES_128_CBC_SHA256:
            return @"TLS PSK with AES 128 CBC SHA256";
        case TLS_PSK_WITH_AES_256_CBC_SHA384:
            return @"TLS PSK with AES 256 CBC SHA384";
        case TLS_PSK_WITH_NULL_SHA256:
            return @"TLS PSK with NULL SHA256";
        case TLS_PSK_WITH_NULL_SHA384:
            return @"TLS PSK with NULL SHA384";
        case TLS_DHE_PSK_WITH_AES_128_CBC_SHA256:
            return @"TLS DHE PSK with AES 128 CBC SHA256";
        case TLS_DHE_PSK_WITH_AES_256_CBC_SHA384:
            return @"TLS DHE PSK with AES 256 CBC SHA384";
        case TLS_DHE_PSK_WITH_NULL_SHA256:
            return @"TLS DHE PSK with NULL SHA256";
        case TLS_DHE_PSK_WITH_NULL_SHA384:
            return @"TLS DHE PSK with NULL SHA384";
        case TLS_RSA_PSK_WITH_AES_128_CBC_SHA256:
            return @"TLS RSA PSK with AES 128 CBC SHA256";
        case TLS_RSA_PSK_WITH_AES_256_CBC_SHA384:
            return @"TLS RSA PSK with AES 256 CBC SHA384";
        case TLS_RSA_PSK_WITH_NULL_SHA256:
            return @"TLS RSA PSK with NULL SHA256";
        case TLS_RSA_PSK_WITH_NULL_SHA384:
            return @"TLS RSA PSK with NULL SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"TLS ECDHE ECDSA with AES 128 CBC SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"TLS ECDHE ECDSA with AES 256 CBC SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256:
            return @"TLS ECDH ECDSA with AES 128 CBC SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384:
            return @"TLS ECDH ECDSA with AES 256 CBC SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS ECDHE RSA with AES 128 CBC SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return @"TLS ECDHE RSA with AES 256 CBC SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256:
            return @"TLS ECDH RSA with AES 128 CBC SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384:
            return @"TLS ECDH RSA with AES 256 CBC SHA384";
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"TLS ECDHE ECDSA with AES 128 GCM SHA256";
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"TLS ECDHE ECDSA with AES 256 GCM SHA384";
        case TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256:
            return @"TLS ECDH ECDSA with AES 128 GCM SHA256";
        case TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384:
            return @"TLS ECDH ECDSA with AES 256 GCM SHA384";
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS ECDHE RSA with AES 128 GCM SHA256";
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS ECDHE RSA with AES 256 GCM SHA384";
        case TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256:
            return @"TLS ECDH RSA with AES 128 GCM SHA256";
        case TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384:
            return @"TLS ECDH RSA with AES 256 GCM SHA384";
        case TLS_EMPTY_RENEGOTIATION_INFO_SCSV:
            return @"TLS EMPTY RENEGOTIATION INFO SCSV";
        case SSL_RSA_WITH_RC2_CBC_MD5:
            return @"SSL RSA with RC2 CBC MD5";
        case SSL_RSA_WITH_IDEA_CBC_MD5:
            return @"SSL RSA with IDEA CBC MD5";
        case SSL_RSA_WITH_DES_CBC_MD5:
            return @"SSL RSA with DES CBC MD5";
        case SSL_RSA_WITH_3DES_EDE_CBC_MD5:
            return @"SSL RSA with 3DES EDE CBC MD5";
        case SSL_NO_SUCH_CIPHERSUITE:
            return @"SSL NO SUCH CIPHERSUITE";
    }

    return @"Unknown";
}

- (NSString *)protocolString {
    switch (self.protocol) {
        case kSSLProtocolUnknown:
            return @"Unknown";
        case kSSLProtocol3:
            return @"SSLv3";
        case kTLSProtocol1:
            return @"TLS 1.0";
        case kTLSProtocol11:
            return @"TLS 1.1";
        case kTLSProtocol12:
            return @"TLS 1.2";
        case kDTLSProtocol1:
            return @"DTLS 1";
        case kSSLProtocol2:
            return @"SSLv2";
        case kSSLProtocol3Only:
            return @"SSLv3 (Only)";
        case kTLSProtocol1Only:
            return @"TLS 1.0 (Only)";
        case kSSLProtocolAll:
            return @"All";
    }
    
    return @"Unknown";
}

@end
