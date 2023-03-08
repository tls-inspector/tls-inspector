//
//  CKOpenSSLCertificateChainGetter.m
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

#import "CKOpenSSLCertificateChainGetter.h"
#import "CKCertificate.h"
#import "CKCertificateChain.h"
#import "CKOCSPManager.h"
#import "CKCRLManager.h"
#import "CKSocketUtils.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <openssl/err.h>
#include <arpa/inet.h>
#include <mach/mach_time.h>

@interface CKOpenSSLCertificateChainGetter ()

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

@implementation CKOpenSSLCertificateChainGetter

static X509 * certificateChain[CERTIFICATE_CHAIN_MAXIMUM];
static int numberOfCerts = 0;
static CFMutableStringRef keyLog = NULL;

INSERT_OPENSSL_ERROR_METHOD

#define SSL_CLEANUP if (conn != NULL) { BIO_free_all(conn); }; if (ctx != NULL) { SSL_CTX_free(ctx); };

- (void) failWithError:(CKCertificateError)code description:(NSString *)description {
    PError(@"Failing with error (%ld): %@", (long)code, description);
    self.finished = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(getter:failedTaskWithError:)]) {
        [self.delegate getter:self failedTaskWithError:MAKE_ERROR(code, description)];
    }
}

- (void) performTaskWithParameters:(CKGetterParameters *)parameters {
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
        [self openSSLError];
        [self failWithError:CKCertificateErrorCrypto description:@"Unsupported client method"];
        SSL_CLEANUP
        return;
    }

    SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, verify_callback);
    SSL_CTX_set_verify_depth(ctx, CERTIFICATE_CHAIN_MAXIMUM);
    SSL_CTX_set_options(ctx, SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_COMPRESSION);
    SSL_CTX_set_keylog_callback(ctx, key_callback);

    conn = BIO_new_ssl_connect(ctx);
    if (conn == NULL) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Connection setup failed"];
        SSL_CLEANUP
        return;
    }

    const char * host = [self.parameters.socketAddress UTF8String];
    if (BIO_set_conn_hostname(conn, host) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorInvalidParameter description:@"Invalid hostname"];
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
        [self openSSLError];
        [self failWithError:CKCertificateErrorCrypto description:@"SSL/TLS connection failure"];
        SSL_CLEANUP
        return;
    }

    const char * PREFERRED_CIPHERS = "HIGH:!aNULL:!MD5:!RC4";
    if (self.parameters.ciphers != nil && self.parameters.ciphers.length > 0) {
        PREFERRED_CIPHERS = [self.parameters.ciphers UTF8String];
    }
    PDebug(@"Requesting ciphers: %s", PREFERRED_CIPHERS);
    if (SSL_set_cipher_list(ssl, PREFERRED_CIPHERS) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorCrypto description:@"Unsupported client ciphersuite"];
        SSL_CLEANUP
        return;
    }

    if (SSL_set_tlsext_host_name(ssl, [self.parameters.hostAddress UTF8String]) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Could not resolve hostname"];
        SSL_CLEANUP
        return;
    }

    if (BIO_do_connect(conn) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Connection failed"];
        SSL_CLEANUP
        return;
    }

    int sock_fd;
    if (BIO_get_fd(conn, &sock_fd) == -1) {
        [self failWithError:CKCertificateErrorInvalidParameter description:@"Internal Error"];
        SSL_CLEANUP
        return;
    }

    NSString * remoteAddr = [CKSocketUtils remoteAddressForSocket:sock_fd];
    if (remoteAddr == nil) {
        [self failWithError:CKCertificateErrorInvalidParameter description:@"No Peer Address"];
        SSL_CLEANUP
        return;
    }

    if (BIO_do_handshake(conn) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Connection failed"];
        SSL_CLEANUP
        return;
    }

    if (numberOfCerts > CERTIFICATE_CHAIN_MAXIMUM) {
        PError(@"Server returned too many certificates. Count: %i, Max: %i", numberOfCerts, CERTIFICATE_CHAIN_MAXIMUM);
        [self failWithError:CKCertificateErrorConnection description:@"Too many certificates from server"];
        SSL_CLEANUP
        return;
    }

    if (numberOfCerts < 1) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Unsupported server configuration"];
        SSL_CLEANUP
        return;
    }

    self.chain = [CKCertificateChain new];
    const SSL_CIPHER * cipher = SSL_get_current_cipher(ssl);
    self.chain.protocol = [self protocolString:SSL_version(ssl)];
    self.chain.cipherSuite = [NSString stringWithUTF8String:SSL_CIPHER_get_name(cipher)];
    self.chain.remoteAddress = remoteAddr;
    PDebug(@"Connected to '%@' (%@), Protocol version: %@, Ciphersuite: %@. Server returned %d certificates", self.parameters.hostAddress, remoteAddr, self.chain.protocol, self.chain.cipherSuite, numberOfCerts);

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

    SSL_CLEANUP

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
        cert = certificateChain[i];
        if (cert) {
            unsigned char * bytes = NULL;
            int len = i2d_X509(cert, &bytes);
            if (len == 0) {
                PError(@"Error converting libssl.X509* to DER bytes");
                [self openSSLError];
                continue;
            }
            NSData * certData = [NSData dataWithBytes:bytes length:len];
            SecCertificateRef secCert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
            if (secCert == NULL) {
                PError(@"Invalid certificate data passed to SecCertificateCreateWithData");
                continue;
            }
            [secCertificates addObject:(__bridge id)secCert];
        }
    }

    if (secCertificates.count == 0) {
        PError(@"SecCertificateCreateWithData refused to parse any certificates presented by the server");
        [self failWithError:CKCertificateErrorInvalidParameter description:@"No valid certificates presented by server"];
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
        [certs addObject:[CKCertificate fromSecCertificateRef:SecTrustGetCertificateAtIndex(trust, i)]];
    }

    self.chain.certificates = certs;
    self.chain.domain = self.parameters.hostAddress;

    if (certs.count == 0) {
        PError(@"No certificates presented by server");
        [self failWithError:CKCertificateErrorInvalidParameter description:@"No certificates presented by server."];
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

- (NSString *) protocolString:(int)protocol {
    switch (protocol) {
        case TLS1_3_VERSION:
            return @"TLS 1.3";
        case TLS1_2_VERSION:
            return @"TLS 1.2";
        case TLS1_1_VERSION:
            return @"TLS 1.1";
        case TLS1_VERSION:
            return @"TLS 1.0";
        case SSL3_VERSION:
            return @"SSL 3.0";
        case SSL2_VERSION:
            return @"SSL 2.0";
    }

    return @"Unknown";
}

@end
