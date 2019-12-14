//
//  CKCertificate.m
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

#import "CKCertificate.h"
#import "NSDate+ASN1_TIME.h"

#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/bn.h>
#include <CommonCrypto/CommonCrypto.h>

@interface CKCertificate()

@property (nonatomic) X509 * certificate;
@property (strong, nonatomic, readwrite) NSString * summary;
@property (strong, nonatomic) NSArray<CKAlternateNameObject *> * subjectAltNames;
@property (strong, nonatomic, readwrite) CKCertificatePublicKey * publicKey;
@property (strong, nonatomic, nonnull, readwrite) CKNameObject * subject;
@property (strong, nonatomic, nonnull, readwrite) CKNameObject * issuer;

@property (strong, nonatomic, nullable, readwrite) NSDate * notAfter;
@property (strong, nonatomic, nullable, readwrite) NSDate * notBefore;
@property (nonatomic, readwrite) BOOL isValidDate;
@property (nonatomic, readwrite) BOOL isExpired;
@property (nonatomic, readwrite) BOOL isNotYetValid;

@property (strong, nonatomic, nullable, readwrite) NSURL * ocspURL;
@property (strong, nonatomic, nullable, readwrite) NSArray<NSURL *> * crlDistributionPoints;
@property (strong, nonatomic, nullable, readwrite) NSArray<NSString *> * tlsFeatures;
@property (strong, nonatomic, nullable, readwrite) NSDictionary<NSString *, NSString *> * keyIdentifiers;

@end

@implementation CKCertificate

INSERT_OPENSSL_ERROR_METHOD

+ (CKCertificate * _Nullable) fromSecCertificateRef:(SecCertificateRef _Nonnull)cert {
    NSData * certificateData = (NSData *)CFBridgingRelease(SecCertificateCopyData(cert));
    const unsigned char * bytes = (const unsigned char *)[certificateData bytes];
    // This will leak
    X509 * xcert = d2i_X509(NULL, &bytes, [certificateData length]);
    certificateData = nil;
    return [CKCertificate fromX509:xcert];
}

+ (CKCertificate *) fromX509:(void *)cert {
    CKCertificate * xcert = [CKCertificate new];
    xcert.certificate = (X509 *)cert;
    xcert.publicKey = [CKCertificatePublicKey infoFromCertificate:xcert];
    xcert.subject = [CKNameObject fromSubject:X509_get_subject_name(cert)];
    xcert.issuer = [CKNameObject fromSubject:X509_get_issuer_name(cert)];

    // Keep trying with each subject name for the summary
    if (xcert.subject.commonNames.count > 0) {
        xcert.summary = xcert.subject.commonNames[0];
    } else if (xcert.subject.organizationalUnits.count > 0) {
        xcert.summary = xcert.subject.organizationalUnits[0];
    } else if (xcert.subject.organizations.count > 0) {
        xcert.summary = xcert.subject.organizations[0];
    } else if (xcert.subject.emailAddresses.count > 0) {
        xcert.summary = xcert.subject.emailAddresses[0];
    } else if (xcert.subject.countryCodes.count > 0) {
        xcert.summary = xcert.subject.countryCodes[0];
    } else if (xcert.subject.states.count > 0) {
        xcert.summary = xcert.subject.states[0];
    } else if (xcert.subject.cities.count > 0) {
        xcert.summary = xcert.subject.cities[0];
    } else {
        xcert.summary = @"Untitled Certificate";
    }

    xcert.notAfter = [NSDate fromASN1_TIME:X509_get0_notAfter(cert)];
    xcert.notBefore = [NSDate fromASN1_TIME:X509_get0_notBefore(cert)];

    // Don't consider certs expired/notyetvalid if they're just hours away from the date.
    xcert.isExpired = [xcert.notAfter timeIntervalSinceNow] < 86400;
    xcert.isNotYetValid = [xcert.notBefore timeIntervalSinceNow] > 86400;
    xcert.isValidDate = !xcert.isExpired && !xcert.isNotYetValid;

    // Get the OCSP URL
    {
        AUTHORITY_INFO_ACCESS * info = X509_get_ext_d2i(cert, NID_info_access, NULL, NULL);
        int len = sk_ACCESS_DESCRIPTION_num(info);
        for (int i = 0; i < len; i++) {
            // Look for the OCSP entry
            ACCESS_DESCRIPTION * description = sk_ACCESS_DESCRIPTION_value(info, i);
            if (OBJ_obj2nid(description->method) == NID_ad_OCSP) {
                if (description->location->type == GEN_URI) {
                    char * ocspurlchar = i2s_ASN1_IA5STRING(NULL, description->location->d.ia5);
                    NSString * ocspurlString = [[NSString alloc] initWithUTF8String:ocspurlchar];
                    xcert.ocspURL = [NSURL URLWithString:ocspurlString];
                }
            }
        }
        AUTHORITY_INFO_ACCESS_free(info);
    }

    // Get CLR Distribution points
    {
        CRL_DIST_POINTS * points = X509_get_ext_d2i(cert, NID_crl_distribution_points, NULL, NULL);
        int numberOfPoints = sk_DIST_POINT_num(points);
        if (numberOfPoints < 0) {
            xcert.crlDistributionPoints = @[];
        } else {
            DIST_POINT * point;
            GENERAL_NAMES * fullNames;
            GENERAL_NAME * fullName;
            NSMutableArray<NSURL *> * urls = [NSMutableArray new];
            for (int i = 0; i < numberOfPoints; i ++) {
                point = sk_DIST_POINT_value(points, i);
                fullNames = point->distpoint->name.fullname;
                fullName = sk_GENERAL_NAME_value(fullNames, 0);
                const unsigned char * url = ASN1_STRING_get0_data(fullName->d.uniformResourceIdentifier);
                NSURL * crlURL = [NSURL URLWithString:[NSString stringWithUTF8String:(const char *)url]];
                if (crlURL != nil && [crlURL.absoluteString hasPrefix:@"http"]) {
                    [urls addObject:crlURL];
                } else {
                    PDebug(@"Unsupported CRL distribution point: %s", url);
                }
            }
            xcert.crlDistributionPoints = urls;
        }
        CRL_DIST_POINTS_free(points);
    }

    // Get any TLS features
    {
        TLS_FEATURE * tlsFeatures = X509_get_ext_d2i(cert, NID_tlsfeature, NULL, NULL);
        int len = sk_ASN1_INTEGER_num(tlsFeatures);
        if (len > 0) {
            NSDictionary<NSNumber *, NSString *> * tlsFeatureIDs = @{
                                                                     @5: @"tls_feature_status_request",
                                                                     @15: @"tls_feature_status_request_v2",
                                                                     };

            NSMutableArray<NSString *> * featureNames = [NSMutableArray arrayWithCapacity:len];
            for (int i = 0; i < len; i++) {
                ASN1_INTEGER * feature = sk_ASN1_INTEGER_value(tlsFeatures, i);
                NSNumber * featureID = [NSNumber numberWithLong:ASN1_INTEGER_get(feature)];
                NSString * featureName = tlsFeatureIDs[featureID];
                if (featureName == nil) {
                    PError(@"Unknown TLS feature ID %lu", featureID.longValue);
                    [featureNames addObject:[NSString stringWithFormat:@"Unknown Feature %lu", featureID.longValue]];
                } else {
                    [featureNames addObject:featureName];
                }
            }
            xcert.tlsFeatures = featureNames;
        }
        TLS_FEATURE_free(tlsFeatures);
    }

    // Get key identifiers
    {
        NSMutableDictionary<NSString *, NSString *> * identifiers = [NSMutableDictionary new];

        ASN1_OCTET_STRING * subjectIdentifier = X509_get_ext_d2i(cert, NID_subject_key_identifier, NULL, NULL);
        AUTHORITY_KEYID * authorityIdentifier = X509_get_ext_d2i(cert, NID_authority_key_identifier, NULL, NULL);

        if (subjectIdentifier != NULL && subjectIdentifier->data != NULL) {
            NSString * subject = [CKCertificate asn1OctetStringToHexString:subjectIdentifier];
            if (subject != nil) {
                identifiers[@"subject"] = subject;
            }
        }

        if (authorityIdentifier != NULL && authorityIdentifier->keyid != NULL) {
            NSString * authority = [CKCertificate asn1OctetStringToHexString:authorityIdentifier->keyid];
            if (authority != nil) {
                identifiers[@"authority"] = authority;
            }
        }

        if (identifiers.allKeys.count > 0) {
            xcert.keyIdentifiers = identifiers;
        }
    }

    {
        CERTIFICATEPOLICIES * policies = X509_get_ext_d2i(cert, NID_certificate_policies, NULL, NULL);
        int len = sk_POLICYINFO_num(policies);
        if (len > 0) {
            for (int i = 0; i < len; i++) {
                POLICYINFO * info = sk_POLICYINFO_value(policies, i);
                ASN1_OBJECT * policyID = info->policyid;
                char idBuf[128];
                OBJ_obj2txt(idBuf, sizeof(idBuf), policyID, 0);
                printf("ID: %s\n", idBuf);
            }
        }
    }

    return xcert;
}

- (NSString *) SHA512Fingerprint {
    return [self digestOfType:CKCertificateFingerprintTypeSHA512];
}

- (NSString *) SHA256Fingerprint {
    return [self digestOfType:CKCertificateFingerprintTypeSHA256];
}

- (NSString *) MD5Fingerprint {
    return [self digestOfType:CKCertificateFingerprintTypeMD5];
}

- (NSString *) SHA1Fingerprint {
    return [self digestOfType:CKCertificateFingerprintTypeSHA1];
}

- (NSString *) digestOfType:(CKCertificateFingerprintType)type {
    const EVP_MD * digest;

    switch (type) {
        case CKCertificateFingerprintTypeSHA512:
            digest = EVP_sha512();
            break;
        case CKCertificateFingerprintTypeSHA256:
            digest = EVP_sha256();
            break;
        case CKCertificateFingerprintTypeSHA1:
            digest = EVP_sha1();
            break;
        case CKCertificateFingerprintTypeMD5:
            digest = EVP_md5();
            break;
        default:
            return nil;
    }

    unsigned char fingerprint[EVP_MAX_MD_SIZE];

    unsigned int fingerprint_size = sizeof(fingerprint);
    if (X509_digest(self.certificate, digest, fingerprint, &fingerprint_size) < 0) {
        [self openSSLError];
        PError(@"Unable to generate certificate fingerprint");
        return nil;
    }

    NSMutableString * fingerprintString = [NSMutableString new];

    for (int i = 0; i < fingerprint_size && i < EVP_MAX_MD_SIZE; i++) {
        [fingerprintString appendFormat:@"%02x", fingerprint[i]];
    }

    return fingerprintString;
}

- (BOOL) verifyFingerprint:(NSString *)fingerprint type:(CKCertificateFingerprintType)type {
    NSString * actualFingerprint = [self digestOfType:type];
    NSString * formattedFingerprint = [[fingerprint componentsSeparatedByCharactersInSet:[[NSCharacterSet
                                                                                           alphanumericCharacterSet]
                                                                                          invertedSet]]
                                       componentsJoinedByString:@""];

    return [[actualFingerprint lowercaseString] isEqualToString:[formattedFingerprint lowercaseString]];
}

- (NSString *) serialNumber {
    const ASN1_INTEGER * serial = X509_get0_serialNumber(self.certificate);
    long value = ASN1_INTEGER_get(serial);
    if (value == -1) {
        BIGNUM * bnser = ASN1_INTEGER_to_BN(serial, NULL);
        char * asciiHex = BN_bn2hex(bnser);
        return [NSString stringWithUTF8String:asciiHex];
    } else {
        return [[NSNumber numberWithLong:value] stringValue];
    }
}

- (NSNumber *) version {
    return [NSNumber numberWithLong:X509_get_version((X509 *)self.X509Certificate)];
}

- (NSString *) signatureAlgorithm {
    const X509_ALGOR * sigType = X509_get0_tbs_sigalg(self.certificate);
    char buffer[128];
    OBJ_obj2txt(buffer, sizeof(buffer), sigType->algorithm, 0);
    return [NSString stringWithUTF8String:buffer];
}

- (void *) X509Certificate {
    return self.certificate;
}

- (NSData *) publicKeyAsPEM {
    BIO * buffer = BIO_new(BIO_s_mem());
    if (PEM_write_bio_X509(buffer, self.certificate)) {
        BUF_MEM *buffer_pointer;
        BIO_get_mem_ptr(buffer, &buffer_pointer);
        char * pem_bytes = malloc(buffer_pointer->length);
        memcpy(pem_bytes, buffer_pointer->data, buffer_pointer->length-1);

        // Exclude the null terminator from the NSData object
        NSData * pem = [NSData dataWithBytes:pem_bytes length:buffer_pointer->length -1];

        free(pem_bytes);
        free(buffer);

        return pem;
    }

    free(buffer);
    return nil;
}

- (NSArray<CKAlternateNameObject *> *) alternateNames {
    // Lazy load this as it's leaky and can be really resource heavy for certificates
    // with a crazy amount of names.

    if (self.subjectAltNames) {
        return self.subjectAltNames;
    }

    // This will leak
    GENERAL_NAMES * sans = X509_get_ext_d2i(self.certificate, NID_subject_alt_name, NULL, NULL);
    int numberOfSans = sk_GENERAL_NAME_num(sans);
    if (numberOfSans < 1) {
        return @[];
    }
    if (numberOfSans > 10000) {
        // Enforce a reasonable limit of 10,000 names
        PError(@"Certificate has too many alternate names: %i.", numberOfSans);
        return @[];
    }

    NSMutableArray<CKAlternateNameObject *> * names = [NSMutableArray arrayWithCapacity:numberOfSans];
    const GENERAL_NAME * name;

    for (int i = 0; i < numberOfSans; i++) {
        name = sk_GENERAL_NAME_value(sans, i);
        unsigned char * value = NULL;

        CKAlternateNameObject * nameObject = [CKAlternateNameObject new];

        switch (name->type) {
            case GEN_EMAIL:
                nameObject.type = AlternateNameTypeEmail;
                value = name->d.ia5->data;
                break;
            case GEN_DNS:
                nameObject.type = AlternateNameTypeDNS;
                value = name->d.ia5->data;
                break;
            case GEN_URI:
                nameObject.type = AlternateNameTypeURI;
                value = name->d.ia5->data;
                break;
            case GEN_IPADD:
                nameObject.type = AlternateNameTypeIP;

                unsigned char *p;
                char oline[256], htmp[5];
                int i;
                p = name->d.ip->data;
                if (name->d.ip->length == 4) {
                    snprintf(oline, sizeof(oline), "%d.%d.%d.%d", p[0], p[1], p[2], p[3]);
                    value = (unsigned char *)&oline;
                    printf("IP Address: %s\n", value);
                } else if (name->d.ip->length == 16) {
                    oline[0] = 0;
                    for (i = 0; i < 8; i++) {
                        snprintf(htmp, sizeof(htmp), "%X", p[0] << 8 | p[1]);
                        p += 2;
                        // Use of strcat is acceptable here as we use "snprintf" above.
                        strcat(oline, htmp);
                        if (i != 7) {
                            strcat(oline, ":");
                        }
                    }
                    value = (unsigned char *)&oline;
                }
                break;
            default:
                break;
        }
        if (value != NULL) {
            nameObject.value = [NSString stringWithUTF8String:(const char *)value];
            [names addObject:nameObject];
        }
    }

    self.subjectAltNames = names;
    sk_GENERAL_NAME_free(sans);

    return names;
}

- (NSString *) extendedValidationAuthority {
    CKEVOIDList * evOIDlist = [CKEVOIDList new];
    CERTIFICATEPOLICIES * policies = X509_get_ext_d2i(self.certificate, NID_certificate_policies, NULL, NULL);
    int numberOfPolicies = sk_POLICYINFO_num(policies);

    const POLICYINFO * policy;
    NSString * oid;
    NSString * evAgency;
    for (int i = 0; i < numberOfPolicies; i++) {
        policy = sk_POLICYINFO_value(policies, i);

#define POLICY_BUFF_MAX 32
        char buff[POLICY_BUFF_MAX];
        OBJ_obj2txt(buff, POLICY_BUFF_MAX, policy->policyid, 0);
        oid = [NSString stringWithUTF8String:buff];
        evAgency = [evOIDlist.oidMap objectForKey:oid];
        if (evAgency) {
            sk_POLICYINFO_free(policies);
            return evAgency;
        }
    }

    sk_POLICYINFO_free(policies);
    return nil;
}

- (BOOL) isCA {
    BASIC_CONSTRAINTS * constraints = X509_get_ext_d2i(self.certificate, NID_basic_constraints, NULL, NULL);
    if (constraints) {
        BOOL ret = constraints->ca > 0;
        BASIC_CONSTRAINTS_free(constraints);
        return ret;
    } else {
        return NO;
    }
}

- (BOOL) extendedValidation {
    return [self extendedValidationAuthority] != nil;
}

- (NSArray<NSString *> *) keyUsage {
    int crit = -1;
    int idx = -1;
    ASN1_BIT_STRING *keyUsage = (ASN1_BIT_STRING *)X509_get_ext_d2i(self.certificate, NID_key_usage, &crit, &idx);
    NSArray<NSString *> * usages = @[@"digitalSignature",
                                     @"nonRepudiation",
                                     @"keyEncipherment",
                                     @"dataEncipherment",
                                     @"keyAgreement",
                                     @"keyCertSign",
                                     @"cRLSign",
                                     @"encipherOnly",
                                     @"decipherOnly"];
    NSMutableArray<NSString *> * values = [NSMutableArray arrayWithCapacity:usages.count];
    for (int i = 0; i < usages.count; i++) {
        if (ASN1_BIT_STRING_get_bit(keyUsage, i)) {
            [values addObject:usages[i]];
        }
    }
    return values;
}

- (NSArray<NSString *> *) extendedKeyUsage {
    int crit = -1;
    int idx = -1;
    ASN1_BIT_STRING *keyUsage = (ASN1_BIT_STRING *)X509_get_ext_d2i(self.certificate, NID_ext_key_usage, &crit, &idx);
    NSArray<NSString *> * usages = @[@"anyExtendedKeyUsage",
                                     @"serverAuth",
                                     @"clientAuth",
                                     @"codeSigning",
                                     @"emailProtection",
                                     @"timeStamping",
                                     @"OCSPSigning"];
    NSMutableArray<NSString *> * values = [NSMutableArray arrayWithCapacity:usages.count];
    for (int i = 0; i < usages.count; i++) {
        if (ASN1_BIT_STRING_get_bit(keyUsage, i)) {
            [values addObject:usages[i]];
        }
    }
    return values;
}

+ (NSString *) asn1OctetStringToHexString:(ASN1_OCTET_STRING *)str {
    unsigned char * buffer = str->data;
    int len = str->length;

    char *tmp, *q;
    const unsigned char *p;
    int i;
    static const char hexdig[] = "0123456789ABCDEF";
    if (!buffer || !len)
        return nil;
    if (!(tmp = malloc(len * 3 + 1))) {
        return nil;
    }
    q = tmp;
    for (i = 0, p = buffer; i < len; i++, p++) {
        *q++ = hexdig[(*p >> 4) & 0xf];
        *q++ = hexdig[*p & 0xf];
        *q++ = ':';
    }
    q[-1] = 0;

    NSString * string = [[NSString alloc] initWithUTF8String:tmp];
    free(tmp);
    return string;
}

@end
