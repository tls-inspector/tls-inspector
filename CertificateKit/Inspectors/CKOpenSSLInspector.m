//
//  CKOpenSSLInspector.m
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

#import "CKOpenSSLInspector.h"
#import "CKOpenSSLInspector+EnumValues.h"
#import "CKCertificate.h"
#import "CKCertificateChain.h"
#import "CKOCSPManager.h"
#import "CKCRLManager.h"
#import "CKSocketUtils.h"
#import "CKHTTPClient.h"
#import "CKInspectParameters+Private.h"
#import "CKHTTPServerInfo+Private.h"
#import "CKLogging+Private.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <arpa/inet.h>
#include <mach/mach_time.h>

@interface CKOpenSSLInspector ()

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

@implementation CKOpenSSLInspector

static X509 * certificateChain[CERTIFICATE_CHAIN_MAXIMUM];
static int numberOfCerts = 0;
static CFMutableStringRef keyLog = NULL;

#define SSL_CLEANUP if (ctx != NULL) { SSL_CTX_free(ctx); };

- (void) executeWithParameters:(CKInspectParameters *)parameters completed:(void (^)(CKInspectResponse *, NSError *))completed {
    uint64_t startTime = mach_absolute_time();
    PDebug(@"Getting certificate chain with OpenSSL");

    self.parameters = parameters;

    for (int i = 0; i < CERTIFICATE_CHAIN_MAXIMUM; i++) {
        certificateChain[i] = NULL;
    }
    numberOfCerts = 0;

    SSL_CTX * ctx = NULL;
    BIO * conn = NULL;
    SSL * ssl = NULL;

    ctx = SSL_CTX_new(TLS_client_method());
    if (ctx == NULL) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorCrypto, @"Unsupported client method"));
        SSL_CLEANUP
        return;
    }

    SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, verify_callback);
    SSL_CTX_set_verify_depth(ctx, CERTIFICATE_CHAIN_MAXIMUM);
    SSL_CTX_set_options(ctx, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_COMPRESSION);
    SSL_CTX_set_keylog_callback(ctx, key_callback);

    conn = BIO_new_ssl_connect(ctx);
    if (conn == NULL) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorConnection, @"Connection setup failed"));
        SSL_CLEANUP
        return;
    }

    const char * host = [self.parameters.socketAddress UTF8String];
    if (BIO_set_conn_hostname(conn, host) < 0) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorInvalidParameter, @"Invalid hostname"));
        SSL_CLEANUP
        return;
    }

    switch (parameters.ipVersion) {
        case IP_VERSION_AUTOMATIC:
            BIO_set_conn_ip_family(conn, BIO_FAMILY_IPANY);
            break;
        case IP_VERSION_IPV4:
            BIO_set_conn_ip_family(conn, BIO_FAMILY_IPV4);
            break;
        case IP_VERSION_IPV6:
            BIO_set_conn_ip_family(conn, BIO_FAMILY_IPV6);
            break;
    }

    BIO_get_ssl(conn, &ssl);
    if (ssl == NULL) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorCrypto, @"SSL/TLS connection failure"));
        SSL_CLEANUP
        return;
    }

    const char * PREFERRED_CIPHERS = "HIGH:!aNULL:!MD5:!RC4";
    if (self.parameters.ciphers != nil && self.parameters.ciphers.length > 0) {
        PREFERRED_CIPHERS = [self.parameters.ciphers UTF8String];
    }
    PDebug(@"Requesting ciphers: %s", PREFERRED_CIPHERS);
    if (SSL_set_cipher_list(ssl, PREFERRED_CIPHERS) < 0) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorCrypto, @"Unsupported client ciphersuite"));
        SSL_CLEANUP
        return;
    }

    if (SSL_set_tlsext_host_name(ssl, [self.parameters.hostAddress UTF8String]) < 0) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorConnection, @"Could not resolve hostname"));
        SSL_CLEANUP
        return;
    }

    if (BIO_do_connect(conn) < 0) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorConnection, @"Connection failed"));
        SSL_CLEANUP
        return;
    }

    int sock_fd;
    if (BIO_get_fd(conn, &sock_fd) == -1) {
        completed(nil, MAKE_ERROR(CKCertificateErrorInvalidParameter, @"Internal Error"));
        SSL_CLEANUP
        return;
    }

    CKIPAddress * remoteAddr = [CKSocketUtils remoteAddressForSocket:sock_fd];
    if (remoteAddr == nil) {
        completed(nil, MAKE_ERROR(CKCertificateErrorInvalidParameter, @"No Peer Address"));
        SSL_CLEANUP
        return;
    }

    if (BIO_do_handshake(conn) < 0) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorConnection, @"Connection failed"));
        SSL_CLEANUP
        return;
    }

    if (numberOfCerts > CERTIFICATE_CHAIN_MAXIMUM) {
        PError(@"Server returned too many certificates. Count: %i, Max: %i", numberOfCerts, CERTIFICATE_CHAIN_MAXIMUM);
        completed(nil, MAKE_ERROR(CKCertificateErrorConnection, @"Too many certificates from server"));
        SSL_CLEANUP
        return;
    }

    if (numberOfCerts < 1) {
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
        completed(nil, MAKE_ERROR(CKCertificateErrorConnection, @"Unsupported server configuration"));
        SSL_CLEANUP
        return;
    }

    self.chain = [CKCertificateChain new];
    const SSL_CIPHER * cipher = SSL_get_current_cipher(ssl);
    self.chain.protocol = [self protocolString:SSL_version(ssl)];
    self.chain.cipherSuite = [NSString stringWithUTF8String:SSL_CIPHER_get_name(cipher)];
    self.chain.remoteAddress = remoteAddr;
    PDebug(@"Connected to '%@' (%@), Protocol version: %@, Ciphersuite: %@. Server returned %d certificates", self.parameters.hostAddress, remoteAddr, self.chain.protocol, self.chain.cipherSuite, numberOfCerts);

    dispatch_queue_t httpQueue = dispatch_queue_create("com.ecnepsnai.CertificateKit.CKOpenSSLInspector.httpQueue", NULL);
    CKHTTPResponse * __block httpResponse;
    dispatch_block_t getHttpResponse = dispatch_block_create(0, ^{
        NSData * httpRequest = [CKHTTPClient requestForHost:parameters.hostAddress];
        BIO_write(conn, httpRequest.bytes, (int)httpRequest.length);
        httpResponse = [CKHTTPClient responseFromBIO:conn];
    });
    dispatch_barrier_async(httpQueue, getHttpResponse);
    dispatch_block_wait(getHttpResponse, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));
    CKHTTPServerInfo * httpServerInfo;
    if (httpResponse != nil) {
        httpServerInfo = [CKHTTPServerInfo fromHTTPResponse:httpResponse];
    }

    const STACK_OF(SCT) * sct_list = SSL_get0_peer_scts(ssl);
    int numberOfSct = sk_SCT_num(sct_list);
    NSMutableArray<CKSignedCertificateTimestamp *> * timestampList = [NSMutableArray new];
    for (int i = 0; i < numberOfSct; i++) {
        CKSignedCertificateTimestamp * sct = [CKSignedCertificateTimestamp fromSCT:sk_SCT_value(sct_list, i)];
        if (sct == nil) {
            continue;
        }
        [timestampList addObject:sct];
    }
    if (numberOfSct > 0 && timestampList.count > 0) {
        PDebug(@"Got %lu sct from handshake", (unsigned long)timestampList.count);
        self.chain.signedTimestamps = timestampList;
    }

    if (keyLog != NULL) {
        self.chain.keyLog = (__bridge NSString*)keyLog;
    }

    // For security purposes, regular iOS applications are not allowed to access the root CA store
    // for the device. This means that OpenSSL will not be able to determine if a certificate is
    // trusted or get the root CA certificate (as most websites do not present it)
    // The work-around for this is to export and import the certificate into Apple's security
    // library, determine the trust status (which gets the root CA for us).
    // If the security library gave us one more certificate than what the server presented,
    // that's the system-installed root CA
    X509 * cert;
    NSMutableArray * secCertificates = [NSMutableArray arrayWithCapacity:numberOfCerts];
    for (int i = 0; i < numberOfCerts; i++) {
        PDebug(@"Processing certificate %i/%i", i+1, numberOfCerts);
        cert = certificateChain[i];
        if (cert) {
            unsigned char * bytes = NULL;
            int len = i2d_X509(cert, &bytes);
            if (len == 0) {
                PError(@"Error converting libssl.X509* to DER bytes");
                [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
                continue;
            }
            NSData * certData = [NSData dataWithBytes:bytes length:len];
            SecCertificateRef secCert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
            if (secCert == NULL) {
                PError(@"Invalid certificate data passed to SecCertificateCreateWithData");
                continue;
            }
            [secCertificates addObject:(__bridge id)secCert];
            PDebug(@"Processed certificate successfully");
        }
    }

    if (secCertificates.count == 0) {
        PError(@"SecCertificateCreateWithData refused to parse any certificates presented by the server");
        completed(nil, MAKE_ERROR(CKCertificateErrorInvalidParameter, @"No valid certificates presented by server"));
        return;
    }

    SecPolicyRef policy = SecPolicyCreateSSL(true, (__bridge CFStringRef)self.parameters.hostAddress);
    SecTrustRef trust;
    SecTrustCreateWithCertificates((__bridge CFTypeRef)secCertificates, policy, &trust);

    SecTrustResultType trustStatus;
    SecTrustGetTrustResult(trust, &trustStatus);
    if ([CKLogging sharedInstance].level == CKLoggingLevelDebug) {
        CFDictionaryRef trustResultDictionary = SecTrustCopyResult(trust);
        PDebug(@"Trust result details: %@", [(__bridge NSDictionary *)trustResultDictionary description]);
        CFRelease(trustResultDictionary);
    }

    long trustCount = SecTrustGetCertificateCount(trust);
    PDebug(@"Trust returned %ld certificates", trustCount);

    NSMutableArray<CKCertificate *> * certs = [NSMutableArray arrayWithCapacity:trustCount];
    for (int i = 0; i < trustCount; i++) {
        CKCertificate * certificate = [CKCertificate fromSecCertificateRef:SecTrustGetCertificateAtIndex(trust, i)];
        if (i > 0) {
            certificate.revoked = [self getRevokedInformationForCertificate:certificate issuer:certs[i-1]];
        }
        [certs addObject:certificate];
    }

    self.chain.certificates = certs;
    self.chain.domain = self.parameters.hostAddress;

    SSL_CLEANUP

    if (certs.count == 0) {
        PError(@"No certificates presented by server");
        completed(nil, MAKE_ERROR(CKCertificateErrorInvalidParameter, @"No certificates presented by server."));
        return;
    }

    if (trustStatus == kSecTrustResultUnspecified) {
        self.chain.trustStatus = CKCertificateChainTrustStatusTrusted;
    } else if (trustStatus == kSecTrustResultProceed) {
        self.chain.trustStatus = CKCertificateChainTrustStatusLocallyTrusted;
    } else {
        [self.chain determineTrustFailureReason];
    }

    [self.chain checkAuthorityTrust];

    PDebug(@"Certificate chain: %@", [self.chain description]);
    PDebug(@"Finished getting certificate chain");
    completed([CKInspectResponse responseWithCertificateChain:self.chain httpServerInfo:httpServerInfo], nil);

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
        PDebug(@"OpenSSL getter collected certificate information in %fns", elapsedTimeInNanoseconds);
    }
}

int verify_callback(int preverify, X509_STORE_CTX* x509_ctx) {
    STACK_OF(X509) * certs = X509_STORE_CTX_get1_chain(x509_ctx);
    X509 * cert;
    int count = sk_X509_num(certs);
    numberOfCerts = count;
    if (count > CERTIFICATE_CHAIN_MAXIMUM) {
        PError(@"Certificate chain exceeds maximum number of supported certificates: Count: %d, Max: %d", count, CERTIFICATE_CHAIN_MAXIMUM);
        return 0;
    }
    for (int i = 0; i < count; i++) {
        if (i < CERTIFICATE_CHAIN_MAXIMUM) {
            cert = sk_X509_value(certs, i);
            if (cert != NULL) {
                certificateChain[i] = cert;
            }
        }
    }

    return preverify;
}

void key_callback(const SSL *ssl, const char *line) {
    PDebug(@"[NSS_KEYLOG] %s", line);
    if (keyLog == NULL) {
        keyLog = CFStringCreateMutable(NULL, 0);
    }
    CFStringAppendFormat(keyLog, NULL, CFSTR("%s\n"), line);
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
