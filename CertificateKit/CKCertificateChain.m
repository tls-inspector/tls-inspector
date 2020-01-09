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

@implementation CKCertificateChain

// Apple does not provide (as far as I am aware) detailed information as to why a certificate chain
// failed evalulation. Therefor we have to made some deductions based off of information we do know.
// Expired (Any)
- (void) determineTrustFailureReason {
    // Expired/Not Valid
    for (CKCertificate * cert in self.certificates) {
        if (cert.isExpired) {
            PWarn(@"Certificate: '%@' expired on: %@", cert.subject.commonNames, cert.notAfter.description);
            self.trusted = CKCertificateChainTrustStatusInvalidDate;
            return;
        } else if (cert.isNotYetValid) {
            PWarn(@"Certificate: '%@' is not yet valid until: %@", cert.subject.commonNames, cert.notBefore.description);
            self.trusted = CKCertificateChainTrustStatusInvalidDate;
            return;
        }
    }

    // SHA-1 Leaf
    if ([self.server.signatureAlgorithm hasPrefix:@"sha1"]) {
        PWarn(@"Certificate: '%@' is using SHA-1: '%@'", self.server.subject.commonNames, self.server.signatureAlgorithm);
        self.trusted = CKCertificateChainTrustStatusSHA1Leaf;
        return;
    }

    // SHA-1 Intermediate
    if ([self.intermediateCA.signatureAlgorithm hasPrefix:@"sha1"]) {
        PWarn(@"Certificate: '%@' is using SHA-1: '%@'", self.intermediateCA.subject.commonNames, self.intermediateCA.signatureAlgorithm);
        self.trusted = CKCertificateChainTrustStatusSHA1Intermediate;
        return;
    }

    // Self-Signed
    if (self.certificates.count == 1) {
        PWarn(@"Chain only contains a single certificate");
        self.trusted = CKCertificateChainTrustStatusSelfSigned;
        return;
    }

    // Revoked Leaf
    if (self.server.revoked.isRevoked) {
        PWarn(@"Certificate: '%@' is revoked", self.server.subject.commonNames);
        self.trusted = CKCertificateChainTrustStatusRevokedLeaf;
        return;
    }

    // Revoked Intermedia
    if (self.intermediateCA.revoked.isRevoked) {
        PWarn(@"Certificate: '%@' is revoked", self.intermediateCA.subject.commonNames);
        self.trusted = CKCertificateChainTrustStatusRevokedIntermediate;
        return;
    }

    // Wrong Host
    if (self.server.alternateNames.count == 0) {
        PWarn(@"Certificate: '%@' has no subject alternate names", self.server.subject.commonNames);
        self.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }
    BOOL match = NO;
    NSArray<NSString *> * domainComponents = [self.domain.lowercaseString componentsSeparatedByString:@"."];
    for (CKAlternateNameObject * name in self.server.alternateNames) {
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
        PWarn(@"Certificate: '%@' has no subject alternate names that match: '%@'", self.server.subject.commonNames, self.domain);
        self.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }

    // Fallback (We don't know)
    PWarn(@"Unable to determine why certificate: '%@' is untrusted", self.server.subject.commonNames);
    self.trusted = CKCertificateChainTrustStatusUntrusted;
    return;
}

@end
