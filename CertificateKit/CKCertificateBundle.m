//
//  CKCertificateBundle.m
//
//  LGPLv3
//
//  Copyright (c) 2022 Ian Spence
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

#import "CKCertificateBundle.h"
#import "NSString+ASN1OctetString.h"
#import "NSData+HexString.h"
#import "CKCertificate+Private.h"
#include <openssl/x509.h>
#include <openssl/pem.h>
#include <openssl/bio.h>
#include <openssl/err.h>

@interface CKCertificateBundle () {
    X509_STORE * caStore;
}

@property (strong, nonatomic, nonnull) NSString * bundlePath;
@property (strong, nonatomic, readwrite, nonnull) NSString * name;
@property (strong, nonatomic, readwrite, nonnull) CKCertificateBundleMetadata * metadata;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> * keyIdMap;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> * subjectHashMap;

@end

@implementation CKCertificateBundle

+ (CKCertificateBundle *) bundleWithName:(NSString *)name bundlePath:(NSString *)filePath metadata:(CKCertificateBundleMetadata *)metadata error:(NSError **)errPtr {
    NSData * pemData = [NSData dataWithContentsOfFile:filePath];
    BIO * pemBio = BIO_new_mem_buf(pemData.bytes, (int)pemData.length);

    PKCS7 *p7 = NULL, *p7i;
    p7 = PKCS7_new();
    if (p7 == NULL) {
        PError(@"Error loading ca bundle: %@", name);
        PRINT_OPENSSL_ERROR
        if (errPtr != nil)
            *errPtr = MAKE_ERROR(100, @"Error initalizing PKCS7 object");
        return nil;
    }
    p7i = PEM_read_bio_PKCS7(pemBio, &p7, NULL, NULL);
    if (p7i == NULL) {
        PError(@"Error loading ca bundle: %@", name);
        PRINT_OPENSSL_ERROR
        if (errPtr != nil)
            *errPtr = MAKE_ERROR(100, @"Error reading PKCS7 file");
        return nil;
    }


    BIO_free(pemBio);

    if (p7->d.sign == NULL) {
        PError(@"Error loading ca bundle: %@", name);
        if (errPtr != nil)
            *errPtr = MAKE_ERROR(100, @"PKCS7 file does not contain expected object");
        return nil;
    }

    STACK_OF(X509) *certs = NULL;

    int itype = OBJ_obj2nid(p7->type);
    switch (itype) {
    case NID_pkcs7_signed:
        if (p7->d.sign != NULL) {
            certs = p7->d.sign->cert;
        }
        break;
    case NID_pkcs7_signedAndEnveloped:
        if (p7->d.signed_and_enveloped != NULL) {
            certs = p7->d.signed_and_enveloped->cert;
        }
        break;
    default:
        break;
    }

    int i, count;
    count = sk_X509_num(certs);

    if (count <= 0) {
        PError(@"No certificates in bundle: %@", name);
        if (errPtr != nil)
            *errPtr = MAKE_ERROR(100, @"No certificates found in PKCS7 bundle");
        return nil;
    }

    X509 *x;
    X509_STORE * caStore = X509_STORE_new();
    NSMutableDictionary<NSString *, NSNumber *> * keyIdMap = [NSMutableDictionary new];
    NSMutableDictionary<NSString *, NSNumber *> * subjectHashMap = [NSMutableDictionary new];

    for (i = 0; i < count; i++) {
        x = sk_X509_value(certs, i);
        if (!X509_STORE_add_cert(caStore, x)) {
            PError(@"Error adding certificate from bundle to store: %@", name);
            PRINT_OPENSSL_ERROR
            if (errPtr != nil)
                *errPtr = MAKE_ERROR(100, @"Error adding certificate from PKCS7 bundle");
            return nil;
        }

        ASN1_OCTET_STRING * subjectIdEx = X509_get_ext_d2i(x, NID_subject_key_identifier, NULL, NULL);
        if (subjectIdEx != NULL && subjectIdEx->data != NULL) {
            NSString * subjectId = [NSString asn1OctetStringToHexString:subjectIdEx];
            if (subjectId != nil) {
                keyIdMap[subjectId] = [NSNumber numberWithInt:i];
            }
        }

        char * nameStr = X509_NAME_oneline(X509_get_subject_name(x), 0, 0);
        NSString * nameHex = [[NSData dataWithBytes:nameStr length:strlen(nameStr)] hexString];
        free(nameStr);
        subjectHashMap[nameHex] = [NSNumber numberWithInt:i];
    }

    PDebug(@"Loaded %i certificates from bundle %@", count, name);
    return [[CKCertificateBundle alloc] initWithName:name x509Store:caStore bundlePath:filePath metadata:metadata keyIdMap:keyIdMap subjectHashMap:subjectHashMap];
}

- (CKCertificateBundle *) initWithName:(NSString *)name x509Store:(X509_STORE *)store bundlePath:(NSString *)bundlePath metadata:(CKCertificateBundleMetadata *)metadata keyIdMap:(NSDictionary<NSString *, NSNumber *> *)keyIdMap subjectHashMap:(NSDictionary<NSString *, NSNumber *> *)subjectHashMap {
    self = [super init];
    self.bundlePath = bundlePath;
    self.name = name;
    self.metadata = metadata;
    self.keyIdMap = keyIdMap;
    self.subjectHashMap = subjectHashMap;
    caStore = store;
    return self;
}

- (BOOL) validateCertificates:(NSArray<CKCertificate *> *)certificates {
    if (caStore == NULL) {
        return false;
    }

    X509 * target = certificates[0].X509Certificate;
    STACK_OF(X509) * intermediates = sk_X509_new(NULL);
    for (int i = 1; i < certificates.count; i++) {
        CKCertificate * certificate = certificates[i];
        if (!certificate.isSelfSigned) {
            sk_X509_push(intermediates, (X509 *)certificate.X509Certificate);
        }
    }

    X509_STORE_CTX * ctx = X509_STORE_CTX_new();
    X509_STORE_CTX_init(ctx, caStore, target, intermediates);
    int verify = X509_STORE_CTX_verify(ctx);
    (void)verify;

    STACK_OF(X509) * chain = X509_build_chain(target, intermediates, caStore, 0, NULL, NULL);
    if (chain == NULL) {
        PRINT_OPENSSL_ERROR
    }
    return chain != NULL;
}

- (BOOL) containsCertificate:(CKCertificate *)certificate {
    if (caStore == NULL) {
        return false;
    }

    // First, look for a matching certificate using the key ID
    if (certificate.keyIdentifiers != nil && certificate.keyIdentifiers[@"subject"] != nil) {
        NSString * keyId = certificate.keyIdentifiers[@"subject"];
        NSNumber * idxNum = self.keyIdMap[keyId];
        if (idxNum == nil) {
            return NO;
        }

        STACK_OF(X509) * certificates = X509_STORE_get1_all_certs(caStore);
        X509 * checkCertificate = sk_X509_value(certificates, idxNum.intValue);
        return (X509_cmp(certificate.X509Certificate, checkCertificate));
    }

    // Next, look for a matching certificate using a hash of the subject
    char * nameStr = X509_NAME_oneline(X509_get_subject_name(certificate.X509Certificate), 0, 0);
    NSString * nameHex = [[NSData dataWithBytes:nameStr length:strlen(nameStr)] hexString];
    free(nameStr);
    NSNumber * idxNum = self.subjectHashMap[nameHex];
    if (idxNum != nil) {
        STACK_OF(X509) * certificates = X509_STORE_get1_all_certs(caStore);
        X509 * checkCertificate = sk_X509_value(certificates, idxNum.intValue);
        return (X509_cmp(certificate.X509Certificate, checkCertificate));
    }

    // Failing that, iterate through the certificates in the store
    STACK_OF(X509) * certificates = X509_STORE_get1_all_certs(caStore);
    int count = sk_X509_num(certificates);
    BOOL found = NO;
    X509 * checkCertificate = NULL;
    for (int i = 0; i < count; i++) {
        checkCertificate = sk_X509_pop(certificates);
        if (X509_cmp(checkCertificate, certificate.X509Certificate) == 0) {
            found = YES;
            break;
        }
    }
    sk_X509_free(certificates);
    X509_free(checkCertificate);
    return found;
}

- (BOOL) embedded {
    return ![self.bundlePath containsString:@"rootca"];
}

@end
