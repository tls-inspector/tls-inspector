//
//  CKCertificate.m
//
//  LGPLv3
//
//  Copyright (c) 2016 Ian Spence
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

#import "CKCertificate.h"
#import "NSDate+ASN1_TIME.h"
#import "NSDate+GeneralizedTime.h"
#import "NSString+ASN1OctetString.h"
#import "CKLogging+Private.h"
#import "CKCertificateExtension+Private.h"
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/bio.h>
#include <openssl/bn.h>
#include <CommonCrypto/CommonCrypto.h>

@interface CKCertificate()

@property (nonatomic) X509 * certificate;
@property (strong, nonatomic, nonnull, readwrite) NSString * summary;
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
@property (strong, nonatomic, nullable, readwrite) NSArray<CKCertificateExtension *> * extraExtensions;

@end

@implementation CKCertificate

+ (CKCertificate * _Nullable) fromSecCertificateRef:(SecCertificateRef _Nonnull)cert {
    NSData * certificateData = (NSData *)CFBridgingRelease(SecCertificateCopyData(cert));
    const unsigned char * bytes = (const unsigned char *)[certificateData bytes];
    // This will leak
    X509 * xcert = d2i_X509(NULL, &bytes, [certificateData length]);
    certificateData = nil;
    return [CKCertificate fromX509:xcert];
}

+ (CKCertificate *) fromX509:(X509 *)cert {
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
    NSCalendar * calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateComponents * components = [calendar components:NSCalendarUnitDay fromDate:xcert.notBefore toDate:xcert.notAfter options:0];
    xcert.validDays = [components day];
    xcert.isExpired = [xcert.notAfter timeIntervalSinceNow] < 0;
    xcert.isNotYetValid = [xcert.notBefore timeIntervalSinceNow] > 0;
    xcert.isValidDate = !xcert.isExpired && !xcert.isNotYetValid;

    // Get the OCSP URL
    {
        AUTHORITY_INFO_ACCESS * info = X509_get_ext_d2i(cert, NID_info_access, NULL, NULL);
        int len = sk_ACCESS_DESCRIPTION_num(info);
        for (int i = 0; i < len; i++) {
            // Look for the OCSP entry
            ACCESS_DESCRIPTION * description = sk_ACCESS_DESCRIPTION_value(info, i);
            if (OBJ_obj2nid(description->method) != NID_ad_OCSP) {
                PDebug(@"Ingoring not OCSP access info");
                continue;
            }
            if (description->location->type != GEN_URI) {
                PDebug(@"Ingoring not URL type OCSP access info");
                continue;
            }
            char * ocspurlchar = i2s_ASN1_IA5STRING(NULL, description->location->d.ia5);
            if (ocspurlchar == NULL) {
                PError(@"Unable to extract URL from OCSP access info");
                continue;
            }
            NSString * ocspurlString = [[NSString alloc] initWithUTF8String:ocspurlchar];
            xcert.ocspURL = [NSURL URLWithString:ocspurlString];
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
                if (fullName->type != GEN_URI) {
                    PDebug(@"Ignoring non-URI type CRL entry");
                    continue;
                }
                const unsigned char * url = ASN1_STRING_get0_data(fullName->d.uniformResourceIdentifier);
                if (url == NULL) {
                    PError(@"Unable to extract URI from CRL dist point");
                    continue;
                }
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

    {
        struct stack_st_SCT * sct_list = X509_get_ext_d2i(cert, NID_ct_precert_scts, NULL, NULL);
        int numberOfSct = sk_SCT_num(sct_list);
        NSMutableArray<CKSignedCertificateTimestamp *> * timestampList = [NSMutableArray new];
        for (int i = 0; i < numberOfSct; i++) {
            CKSignedCertificateTimestamp * sct = [CKSignedCertificateTimestamp fromSCT:sk_SCT_value(sct_list, i)];
            if (sct == nil) {
                continue;
            }
            [timestampList addObject:sct];
        }
        if (numberOfSct) {
            xcert.signedTimestamps = timestampList;
        }
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
            NSString * subject = [NSString asn1OctetStringToHexString:subjectIdentifier];
            if (subject != nil) {
                identifiers[@"subject"] = subject;
            }
        }

        if (authorityIdentifier != NULL && authorityIdentifier->keyid != NULL) {
            NSString * authority = [NSString asn1OctetStringToHexString:authorityIdentifier->keyid];
            if (authority != nil) {
                identifiers[@"authority"] = authority;
            }
        }

        if (identifiers.allKeys.count > 0) {
            xcert.keyIdentifiers = identifiers;
        }
    }

    if ([xcert isSelfSigned]) {
        NSNumber * appleTrusted = @NO;
        NSNumber * googleTrusted = @NO;
        NSNumber * microsoftTrusted = @NO;
        NSNumber * mozillaTrusted = @NO;
        if ([CKRootCACertificateBundleManager sharedInstance].appleBundle != nil && [[CKRootCACertificateBundleManager sharedInstance].appleBundle containsCertificate:xcert]) {
            appleTrusted = @YES;
        }
        if ([CKRootCACertificateBundleManager sharedInstance].googleBundle != nil && [[CKRootCACertificateBundleManager sharedInstance].googleBundle containsCertificate:xcert]) {
            googleTrusted = @YES;
        }
        if ([CKRootCACertificateBundleManager sharedInstance].microsoftBundle != nil && [[CKRootCACertificateBundleManager sharedInstance].microsoftBundle containsCertificate:xcert]) {
            microsoftTrusted = @YES;
        }
        if ([CKRootCACertificateBundleManager sharedInstance].mozillaBundle != nil && [[CKRootCACertificateBundleManager sharedInstance].mozillaBundle containsCertificate:xcert]) {
            mozillaTrusted = @YES;
        }
        xcert.vendorTrustStatus = @{
            @"apple": appleTrusted,
            @"google": googleTrusted,
            @"microsoft": microsoftTrusted,
            @"mozilla": mozillaTrusted,
        };
    }

    NSMutableArray<CKCertificateExtension *> * extraExtensions = [NSMutableArray new];

    X509_EXTENSIONS * extensions = (X509_EXTENSIONS *)X509_get0_extensions(cert);
    int i, numExt;
    numExt = sk_X509_EXTENSION_num(extensions);
    X509_EXTENSION * extension;
    ASN1_OBJECT * object;
    for (i = 0; i < numExt; i++) {
        extension = sk_X509_EXTENSION_value(extensions, i);
        object = X509_EXTENSION_get_object(extension);

        int oid = OBJ_obj2nid(object);
        int crit = X509_EXTENSION_get_critical(extension);

        // Ignore known common extensions
        if (oid == NID_key_usage ||
            oid == NID_ext_key_usage ||
            oid == NID_basic_constraints ||
            oid == NID_subject_alt_name ||
            oid == NID_subject_key_identifier ||
            oid == NID_authority_key_identifier ||
            oid == NID_tlsfeature ||
            oid == NID_ct_precert_scts ||
            oid == NID_crl_distribution_points ||
            oid == NID_info_access) {
            continue;
        }

        ASN1_OCTET_STRING * extension_data = X509_EXTENSION_get_data(extension);
        const unsigned char * octet_string_data = extension_data->data;
        long length = extension_data->length;
        long xlen;
        int tag, xclass;
        int ret = ASN1_get_object(&octet_string_data, &xlen, &tag, &xclass, length);
        if (ret & 0x80) {
            PError(@"Invalid value in extension %i", oid);
            [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
            continue;
        }

        char buff[512];
        OBJ_obj2txt(buff, 512, object, 1);
        NSString * oidStr = [NSString stringWithCString:buff encoding:NSASCIIStringEncoding];

        // We'll try to decode and print the value from some of the common ASN1 tags, the rest just get shown as hex.
        switch (tag) {
            case V_ASN1_VISIBLESTRING:
            case V_ASN1_BIT_STRING:
            case V_ASN1_OCTET_STRING:
            case V_ASN1_UTF8STRING:
            case V_ASN1_PRINTABLESTRING:
            case V_ASN1_T61STRING:
            case V_ASN1_IA5STRING: {
                NSString * value = [NSString stringWithCString:(const char *)octet_string_data encoding:NSUTF8StringEncoding];
                [extraExtensions addObject:[CKCertificateExtension withOID:oidStr stringValue:value critical:crit]];
                break;
            }
            case V_ASN1_BOOLEAN: {
                [extraExtensions addObject:[CKCertificateExtension withOID:oidStr boolValue:(BOOL)extension_data->data[0] critical:crit]];
                break;
            }
            case V_ASN1_INTEGER: {
                long num = 0;
                for (int i = 0; i < xlen; i++) {
                    num = (num << 8) | octet_string_data[i];
                }

                [extraExtensions addObject:[CKCertificateExtension withOID:oidStr numberValue:[NSNumber numberWithLong:num] critical:crit]];
                break;
            }
            case V_ASN1_GENERALIZEDTIME: {
                char timeBuf[xlen];
                for (int i = 0; i < xlen; i++) {
                    timeBuf[i] = octet_string_data[i];
                }
                NSString * dateStr = [[NSString alloc] initWithCString:timeBuf encoding:NSASCIIStringEncoding].uppercaseString;
                NSDate * date = [NSDate fromASN1GeneralizedTime:dateStr];
                if (date == nil) {
                    continue;
                }

                [extraExtensions addObject:[CKCertificateExtension withOID:oidStr dateValue:date critical:crit]];
                break;
            }
        }
    }

    xcert.extraExtensions = extraExtensions;

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
        [CKLogging captureOpenSSLErrorInFile:__FILE__ line:__LINE__];
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

- (BOOL) isSelfSigned {
    return X509_self_signed((X509 *)self.X509Certificate, 0) == 1;
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

- (NSArray<NSString *> *) keyUsage {
    int crit = -1;
    int idx = -1;
    ASN1_BIT_STRING *keyUsage = (ASN1_BIT_STRING *)X509_get_ext_d2i(self.certificate, NID_key_usage, &crit, &idx);
    // KU permissions are defined by their index
    // which is listed in the spec: https://tools.ietf.org/html/rfc5280#section-4.2.1.3
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
    NSMutableArray<NSString *> * usages = [NSMutableArray new];
    EXTENDED_KEY_USAGE * eku = X509_get_ext_d2i(self.certificate, NID_ext_key_usage, NULL, NULL);
    for (int i = 0; i < sk_ASN1_OBJECT_num(eku); i++) {
        int usage = OBJ_obj2nid(sk_ASN1_OBJECT_value(eku, i));
        switch (usage) {
            case NID_server_auth:
                [usages addObject:@"serverAuth"];
                break;
            case NID_client_auth:
                [usages addObject:@"clientAuth"];
                break;
            case NID_email_protect:
                [usages addObject:@"emailProtection"];
                break;
            case NID_code_sign:
                [usages addObject:@"codeSigning"];
                break;
            case NID_OCSP_sign:
                [usages addObject:@"OCSPSigning"];
                break;
            case NID_time_stamp:
                [usages addObject:@"timeStamping"];
                break;
            default:
                PWarn(@"Certificate has unknown extended key usage %u", usage);
                break;
        }
    }
    sk_ASN1_OBJECT_pop_free(eku, ASN1_OBJECT_free);
    return usages;
}

- (NSString *) description {
    BIO * buf = BIO_new(BIO_s_mem());
    X509_print(buf, (X509 *)self.X509Certificate);

    NSMutableData * debugData = [NSMutableData new];
    while (1) {
        unsigned char ref[1024];
        int len = BIO_read(buf, ref, 1024);
        if (len <= 0) {
            break;
        }
        [debugData appendBytes:ref length:len];
    }
    NSString * certificateOut = [[NSString alloc] initWithData:debugData encoding:NSUTF8StringEncoding];
    return certificateOut;
}

@end
