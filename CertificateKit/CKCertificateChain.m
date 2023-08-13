//
//  CKCertificateChain.m
//
//  LGPLv3
//
//  Copyright (c) 2017 Ian Spence
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

#import "CKCertificateChain.h"
#import <arpa/inet.h>

@implementation CKCertificateChain

- (void) checkAuthorityTrust {
    NSArray<NSString *> * knownBadCertificates = @[
        // Version: 3 (0x2)
        // Serial Number: 4096 (0x1000)
        // Signature Algorithm: sha256WithRSAEncryption
        // Issuer: C = RU, O = The Ministry of Digital Development and Communications, CN = Russian Trusted Root CA
        // Validity
        //     Not Before: Mar  1 21:04:15 2022 GMT
        //     Not After : Feb 27 21:04:15 2032 GMT
        // Subject: C = RU, O = The Ministry of Digital Development and Communications, CN = Russian Trusted Root CA
        @"D26D2D0231B7C39F92CC738512BA54103519E4405D68B5BD703E9788CA8ECF31",
    ];

    for (NSString * badFingerprint in knownBadCertificates) {
        for (CKCertificate * cert in self.certificates) {
            NSString * fingerprint = [[cert SHA256Fingerprint] uppercaseString];
            if ([fingerprint isEqualToString:badFingerprint]) {
                PError(@"Certificate: '%@' matches known bad certificate '%@'", cert.subject.description, badFingerprint);
                self.trusted = CKCertificateChainTrustStatusBadAuthority;
                return;
            }
        }
    }
}

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

    // Weak RSA
    for (CKCertificate * certificate in self.certificates) {
        if ([certificate.publicKey isWeakRSA]) {
            PWarn(@"Certificate: '%@' has a weak RSA key", certificate.subject.commonNames);
            self.trusted = CKCertificateChainTrustStatusWeakRSAKey;
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
        if (name.type == AlternateNameTypeDNS) {
            NSArray<NSString *> * nameComponents = [name.value.lowercaseString componentsSeparatedByString:@"."];
            if (domainComponents.count != nameComponents.count) {
                // Invalid
                PWarn(@"Domain components does not match name components. domain='%@' name='%@'", self.domain.lowercaseString, name.value.lowercaseString);
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
        } else if (name.type == AlternateNameTypeIP) {
            // SAN rules don't require that IP addresses be in their fully-expanded form, (i.e. 127.1 is valid and should match 127.0.0.1)
            CKIPAddress * nameValue = [CKIPAddress fromString:name.value];
            if (nameValue == nil) {
                PError(@"Invalid IP address value for IP SAN: '%@'", name.value);
                continue;
            }
            if ([nameValue.full isEqualToString:self.remoteAddress.full]) {
                PDebug(@"Found matching IP address SAN %@", nameValue.description);
                match = YES;
                break;
            }
        } else {
            PWarn(@"Skipping unsupported alternate name type: %lu = %@", (unsigned long)name.type, name.value);
            continue;
        }
    }
    if (!match) {
        PWarn(@"Certificate: '%@' has no subject alternate names that match: '%@' or '%@'", self.server.subject.commonNames, self.domain, self.remoteAddress);
        self.trusted = CKCertificateChainTrustStatusWrongHost;
        return;
    }

    // Server cert is missing serverAuth EKU
    if (![self.server.extendedKeyUsage containsObject:@"serverAuth"]) {
        PWarn(@"Certificate: '%@' is missing required serverAuth key usage permission", self.server);
        self.trusted = CKCertificateChainTrustStatusLeafMissingRequiredKeyUsage;
        return;
    }

    // Issue Date too long
    if (self.server.validDays > 825) {
        PWarn(@"Certificate: '%@' is valid for too long %lu days", self.server.subject.commonNames, (unsigned long)self.server.validDays);
        self.trusted = CKCertificateChainTrustStatusIssueDateTooLong;
        return;
    }


    // Fallback (We don't know)
    PWarn(@"Unable to determine why certificate: '%@' is untrusted", self.server.subject.commonNames);
    self.trusted = CKCertificateChainTrustStatusUntrusted;

    return;
}

- (NSString *) description {
    NSMutableString * description = [NSMutableString string];
    for (int i = 0; i < self.certificates.count; i++) {
        CKCertificate * certificate = self.certificates[i];
        [description appendFormat:@"Certificate %d:", i];
        [description appendString:[certificate description]];
    }
    return description;
}

@end
