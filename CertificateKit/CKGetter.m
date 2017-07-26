#import "CKGetter.h"
#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>

@interface CKGetter () <NSStreamDelegate> {
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream   * inputStream;
    NSOutputStream  * outputStream;
    NSURL * queryURL;
    BOOL gotChain;
    BOOL gotServerInfo;
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

@implementation CKGetter

+ (CKGetter * _Nonnull) newGetter {
    return [CKGetter new];
}

- (void) getInfoForURL:(NSURL *)URL; {
    queryURL = URL;

    self.serverInfo = [CKServerInfo new];
    [NSThread detachNewThreadSelector:@selector(getServerInfo) toTarget:self withObject:nil];

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

- (void) getServerInfo {
    [self.serverInfo getServerInfoForURL:queryURL finished:^(NSError *error) {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:errorGettingServerInfo:)]) {
                [self.delegate getter:self errorGettingServerInfo:error];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:gotServerInfo:)]) {
                [self.delegate getter:self gotServerInfo:self.serverInfo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                gotServerInfo = YES;
                [self checkIfFinished];
            });
        }
    }];
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
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:errorGettingCertificateChain:)]) {
                [self.delegate getter:self errorGettingCertificateChain:[stream streamError]];
            }
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
        if (self.chain.certificates.count == 1) {
            self.chain.trusted = CKCertificateChainTrustStatusSelfSigned;
        } else {
            self.chain.trusted = CKCertificateChainTrustStatusUntrusted;
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
                 if (self.delegate && [self.delegate respondsToSelector:@selector(getter:gotCertificateChain:)]) {
                     [self.delegate getter:self gotCertificateChain:self.chain];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     gotChain = YES;
                     [self checkIfFinished];
                 });
             }];
            return;
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(getter:gotCertificateChain:)]) {
        [self.delegate getter:self gotCertificateChain:self.chain];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        gotChain = YES;
        [self checkIfFinished];
    });
}

- (void) checkIfFinished {
    if (gotChain && gotServerInfo) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishedGetter:)]) {
            [self.delegate finishedGetter:self];
        }
    }
}

@end
