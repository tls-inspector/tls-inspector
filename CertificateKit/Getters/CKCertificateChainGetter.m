//
//  CKCertificateChainGetter.m
//
//  MIT License
//
//  Copyright (c) 2016 Ian Spence
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

#import "CKCertificateChainGetter.h"
#import "CKCertificate.h"
#import "CKCertificateChain.h"
#import "CKOCSPManager.h"
#import "CKCRLManager.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <openssl/err.h>
#include <arpa/inet.h>

@interface CKCertificateChainGetter () {
    NSURL * queryURL;
}

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

@implementation CKCertificateChainGetter

static const int CERTIFICATE_CHAIN_MAXIMUM = 10;
static X509 * certificateChain[CERTIFICATE_CHAIN_MAXIMUM];
static int numberOfCerts = 0;

INSERT_OPENSSL_ERROR_METHOD

#define SSL_CLEANUP if (web != NULL) { BIO_free_all(web); }; if (ctx != NULL) { SSL_CTX_free(ctx); };

- (void) failWithError:(CKCertificateError)code description:(NSString *)description {
    [self.delegate getter:self failedTaskWithError:[NSError errorWithDomain:@"com.tlsinspector.certificatekit" code:code userInfo:@{NSLocalizedDescriptionKey: description}]];
}

- (void) performTaskForURL:(NSURL *)url {
    PDebug(@"Getting certificate chain");
    queryURL = url;
    unsigned int port = queryURL.port != nil ? [queryURL.port unsignedIntValue] : 443;

    for (int i = 0; i < CERTIFICATE_CHAIN_MAXIMUM; i++) {
        certificateChain[i] = NULL;
    }
    numberOfCerts = 0;

    OPENSSL_init_ssl(0, NULL);
    OPENSSL_init_crypto(0, NULL);
    ERR_load_SSL_strings();

    SSL_CTX * ctx = NULL;
    BIO * web = NULL;
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

    web = BIO_new_ssl_connect(ctx);
    if (web == NULL) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Connection setup failed"];
        SSL_CLEANUP
        return;
    }

    const char * host = [[NSString stringWithFormat:@"%@:%i", url.host, port] UTF8String];
    if (BIO_set_conn_hostname(web, host) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorInvalidParameter description:@"Invalid hostname"];
        SSL_CLEANUP
        return;
    }

    BIO_get_ssl(web, &ssl);
    if (ssl == NULL) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorCrypto description:@"SSL/TLS connection failure"];
        SSL_CLEANUP
        return;
    }

    const char* const PREFERRED_CIPHERS = "HIGH:!aNULL:!MD5:!RC4";
    PDebug(@"Requesting ciphers: %s", PREFERRED_CIPHERS);
    if (SSL_set_cipher_list(ssl, PREFERRED_CIPHERS) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorCrypto description:@"Unsupported client ciphersuite"];
        SSL_CLEANUP
        return;
    }

    if (SSL_set_tlsext_host_name(ssl, [url.host UTF8String]) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Could not resolve hostname"];
        SSL_CLEANUP
        return;
    }

    if (BIO_do_connect(web) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Connection failed"];
        SSL_CLEANUP
        return;
    }

    int sock_fd;
    if (BIO_get_fd(web, &sock_fd) == -1) {
        [self failWithError:CKCertificateErrorInvalidParameter description:@"Internal Error"];
        SSL_CLEANUP
        return;
    }
    struct sockaddr addr;
    socklen_t addr_len = sizeof(addr);
    getpeername(sock_fd, &addr, &addr_len);
    NSString * remoteAddr;
    if (addr.sa_family == AF_INET) {
        char addressString[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &((struct sockaddr_in *)&addr)->sin_addr, addressString, INET_ADDRSTRLEN);
        remoteAddr = [[NSString alloc] initWithUTF8String:addressString];
    } else if (addr.sa_family == AF_INET6) {
        char addressString[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &((struct sockaddr_in6 *)&addr)->sin6_addr, addressString, INET6_ADDRSTRLEN);
        remoteAddr = [[NSString alloc] initWithUTF8String:addressString];
    } else {
        [self failWithError:CKCertificateErrorInvalidParameter description:@"Unknown address family"];
        SSL_CLEANUP
        return;
    }

    if (BIO_do_handshake(web) < 0) {
        [self openSSLError];
        [self failWithError:CKCertificateErrorConnection description:@"Connection failed"];
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
    self.chain.protocol = SSL_version(ssl);
    self.chain.cipherSuite = [NSString stringWithUTF8String:SSL_CIPHER_get_name(cipher)];
    self.chain.remoteAddress = remoteAddr;
    PDebug(@"Connected to '%@' (%@), Protocol version: %@, Ciphersuite: %@", url.host, remoteAddr, self.chain.protocolString, self.chain.cipherSuite);
    PDebug(@"Server returned %d certificates during handshake", numberOfCerts);

    SSL_CLEANUP

    // For security purposes, regular iOS applications are not allowed to access the root CA store
    // for the device. This means that OpenSSL will not be able to determine if a certificate is
    // trusted or get the root CA certificate (as most websites do not present it)
    // The work-around for this is to export import the certificate into Apple's security
    // library, determine the trust status (which gets the root CA for us)
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

    SecPolicyRef policy = SecPolicyCreateSSL(true, (__bridge CFStringRef)url.host);
    SecTrustRef trust;
    SecTrustCreateWithCertificates((__bridge CFTypeRef)secCertificates, policy, &trust);

    SecTrustResultType trustStatus;
    SecTrustEvaluate(trust, &trustStatus);

    long trustCount = SecTrustGetCertificateCount(trust);
    PDebug(@"Trust returned %ld certificates", trustCount);

    NSMutableArray<CKCertificate *> * certs = [NSMutableArray arrayWithCapacity:trustCount];
    for (int i = 0; i < trustCount; i++) {
        [certs addObject:[CKCertificate fromSecCertificateRef:SecTrustGetCertificateAtIndex(trust, i)]];
    }

    self.chain.certificates = certs;

    self.chain.domain = queryURL.host;

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
        [self determineTrust];
    }

    if (certs.count > 1) {
        self.chain.rootCA = [self.chain.certificates lastObject];
        self.chain.intermediateCA = [self.chain.certificates objectAtIndex:1];
    }

    PDebug(@"Finished getting certificate chain");
    [self.delegate getter:self finishedTaskWithResult:self.chain];
    self.finished = YES;
}

int verify_callback(int preverify, X509_STORE_CTX* x509_ctx) {
    STACK_OF(X509) * certs = X509_STORE_CTX_get1_chain(x509_ctx);
    X509 * cert;
    int count = sk_X509_num(certs);
    PError(@"Certificate chain exceeds maximum number of supported certificates %d, max: %d. Truncating chain.", count, CERTIFICATE_CHAIN_MAXIMUM);
    for (int i = 0; i < count; i++) {
        if (i < CERTIFICATE_CHAIN_MAXIMUM) {
            cert = sk_X509_value(certs, i);
            if (cert != NULL) {
                certificateChain[i] = cert;
                numberOfCerts ++;
            }
        }
    }

    return preverify;
}

- (CKRevoked *) getRevokedInformationForCertificate:(CKCertificate *)certificate issuer:(CKCertificate *)issuer {
    CKOCSPResponse * ocspResponse;
    CKCRLResponse * crlResponse;
    NSError * ocspError;
    NSError * crlError;
    
    if (self.options.checkOCSP) {
        [[CKOCSPManager sharedManager] queryCertificate:certificate issuer:issuer response:&ocspResponse error:&ocspError];
        if (ocspError != nil) {
            PError(@"OCSP Error: %@", ocspError.description);
        }
    }
    if (self.options.checkCRL) {
        [[CKCRLManager sharedManager] queryCertificate:certificate issuer:issuer response:&crlResponse error:&crlError];
        if (crlError != nil) {
            PError(@"CRL Error: %@", crlError.description);
        }
    }
    return [CKRevoked fromOCSPResponse:ocspResponse andCRLResponse:crlResponse];
}

// Apple does not provide (as far as I am aware) detailed information as to why a certificate chain
// failed evalulation. Therefor we have to made some deductions based off of information we do know.
// Expired (Any)
- (void) determineTrust {
    // Expired/Not Valid
    for (CKCertificate * cert in self.chain.certificates) {
        if (cert.isExpired) {
            PWarn(@"Certificate: '%@' expired on: %@", cert.subject.commonName, cert.notAfter.description);
            self.chain.trusted = CKCertificateChainTrustStatusInvalidDate;
            return;
        } else if (cert.isNotYetValid) {
            PWarn(@"Certificate: '%@' is not yet valid until: %@", cert.subject.commonName, cert.notBefore.description);
            self.chain.trusted = CKCertificateChainTrustStatusInvalidDate;
            return;
        }
    }

    // SHA-1 Leaf
    if ([self.chain.server.signatureAlgorithm hasPrefix:@"sha1"]) {
        PWarn(@"Certificate: '%@' is using SHA-1", self.chain.server.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusSHA1Leaf;
        return;
    }

    // SHA-1 Intermediate
    if ([self.chain.intermediateCA.signatureAlgorithm hasPrefix:@"sha1"]) {
        PWarn(@"Certificate: '%@' is using SHA-1", self.chain.intermediateCA.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusSHA1Intermediate;
        return;
    }

    // Self-Signed
    if (self.chain.certificates.count == 1) {
        PWarn(@"Chain only contains a single certificate");
        self.chain.trusted = CKCertificateChainTrustStatusSelfSigned;
        return;
    }
    
    // Revoked Leaf
    if (self.chain.server.revoked.isRevoked) {
        PWarn(@"Certificate: '%@' is revoked", self.chain.server.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusRevokedLeaf;
        return;
    }
    
    // Revoked Intermedia
    if (self.chain.intermediateCA.revoked.isRevoked) {
        PWarn(@"Certificate: '%@' is revoked", self.chain.intermediateCA.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusRevokedIntermediate;
        return;
    }

    // Wrong Host
    if (self.chain.server.alternateNames.count == 0) {
        PWarn(@"Certificate: '%@' has no subject alternate names", self.chain.server.subject.commonName);
        self.chain.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }
    BOOL match = NO;
    NSArray<NSString *> * domainComponents = [self.chain.domain.lowercaseString componentsSeparatedByString:@"."];
    for (CKAlternateNameObject * name in self.chain.server.alternateNames) {
        NSArray<NSString *> * nameComponents = [name.value.lowercaseString componentsSeparatedByString:@"."];
        if (domainComponents.count != nameComponents.count) {
            // Invalid
            PWarn(@"Domain components does not match name components");
            continue;
        }

        // SAN Rules:
        //
        // Only the first component of the SAN can be a wildcard
        // Valid: *.google.com
        // Invalid: mail.*.google.com
        //
        // Wildcards only match the same-level of the domain. I.E. *.google.com:
        // Match: mail.google.com
        // Match: calendar.google.com
        // Doesn't match: beta.mail.google.com
        BOOL hasWildcard = [nameComponents[0] isEqualToString:@"*"];
        BOOL validComponents = YES;
        for (int i = 0; i < nameComponents.count; i++) {
            if (i == 0) {
                if (![domainComponents[i] isEqualToString:nameComponents[i]] && !hasWildcard) {
                    validComponents = NO;
                    break;
                }
            } else {
                if (![domainComponents[i] isEqualToString:nameComponents[i]]) {
                    validComponents = NO;
                    break;
                }
            }
        }
        if (validComponents) {
            match = YES;
            break;
        }
    }
    if (!match) {
        PWarn(@"Certificate: '%@' has no subject alternate names that match: '%@'", self.chain.server.subject.commonName, self.chain.domain);
        self.chain.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }

    // Fallback (We don't know)
    PWarn(@"Unable to determine why certificate: '%@' is untrusted", self.chain.server.subject.commonName);
    self.chain.trusted = CKCertificateChainTrustStatusUntrusted;
    return;
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

@end
