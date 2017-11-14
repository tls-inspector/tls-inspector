//
//  CKGetter.m
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

#import "CKGetter.h"
#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <curl/curl.h>

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
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> * headers;
@property (nonatomic) NSUInteger statusCode;

@end

@implementation CKGetter

@synthesize headers;

+ (CKGetter * _Nonnull) newGetter {
    return [CKGetter new];
}

- (void) getInfoForURL:(NSURL *)URL; {
    queryURL = URL;

    [NSThread detachNewThreadSelector:@selector(getServerInfo) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(getCertificates) toTarget:self withObject:nil];
}

- (void) getCertificates {
    unsigned int port = queryURL.port != nil ? [queryURL.port unsignedIntValue] : 443;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)queryURL.host, port, &readStream, &writeStream);

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
    [self getServerInfoForURL:queryURL finished:^(NSError *error) {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(getter:errorGettingServerInfo:)]) {
                [self.delegate getter:self errorGettingServerInfo:error];
            }
        } else {
            self.serverInfo = [CKServerInfo new];
            self.serverInfo.headers = self.headers;
            self.serverInfo.statusCode = self.statusCode;
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

- (void) getServerInfoForURL:(NSURL *)url finished:(void (^)(NSError * error))finished {
    CURL * curl;
    CURLcode response;

    curl_global_init(CURL_GLOBAL_DEFAULT);

    self.headers = [NSMutableDictionary new];

    NSError * error;

    curl = curl_easy_init();
    if (curl) {
#ifdef DEBUG
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
#endif

        const char * urlString = url.absoluteString.UTF8String;
        curl_easy_setopt(curl, CURLOPT_URL, urlString);
        // Since we're only concerned with getting the HTTP servers
        // info, we don't do any verification
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, header_callback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, self.headers);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
        // Perform the request, res will get the return code
        response = curl_easy_perform(curl);
        // Check for errors
        if (response != CURLE_OK) {
            NSString * errString = [[NSString alloc] initWithUTF8String:curl_easy_strerror(response)];
            NSLog(@"Error getting server info: %@", errString);
            error = [NSError errorWithDomain:@"libcurl" code:-1 userInfo:@{NSLocalizedDescriptionKey: errString}];
        }

        long http_code = 0;
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
        self.statusCode = http_code;

        // always cleanup
        curl_easy_cleanup(curl);
    } else {
        error = [NSError errorWithDomain:@"libcurl" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unable to create curl session."}];
    }
    curl_global_cleanup();
    finished(error);
}

static size_t header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
    unsigned long len = nitems * size;
    if (len > 2) {
        NSData * data = [NSData dataWithBytes:buffer length:len - 2]; // Trim the \r\n from the end of the header
        NSString * headerValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray<NSString *> * components = [headerValue componentsSeparatedByString:@": "];
        if (components.count < 2) {
            return len;
        }

        NSString * key = components[0];
        NSInteger keyLength = key.length + 1; // Chop off the ":"
        if ((NSInteger)headerValue.length - keyLength < 0) {
            return len;
        }
        NSString * value = [headerValue substringWithRange:NSMakeRange(keyLength, headerValue.length - keyLength)];
        [((__bridge NSMutableDictionary<NSString *, NSString *> *)userdata)
         setObject:value
         forKey:key];
    }

    return len;
}

size_t write_callback(void *buffer, size_t size, size_t nmemb, void *userp) {
    // We don't really care about the actual HTTP body, so just convince CURL that we did something with it
    // (we don't)
    return size * nmemb;
}

- (void) checkIfFinished {
    if (gotChain && gotServerInfo) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishedGetter:)]) {
            [self.delegate finishedGetter:self];
        }
    }
}

@end
