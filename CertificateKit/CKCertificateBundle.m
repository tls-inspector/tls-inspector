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

@end

@implementation CKCertificateBundle

INSERT_OPENSSL_ERROR_METHOD

- (CKCertificateBundle *)initWithWithContentsOfFile:(NSString *)filePath name:(NSString *)name metadata:(CKCertificateBundleMetadata *)metadata {
    self = [super init];
    self.bundlePath = filePath;
    self.name = name;
    self.metadata = metadata;

    NSString * pemData = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    BIO * pemBio = BIO_new_mem_buf(pemData.UTF8String, (int)pemData.length);

    PKCS7 *p7 = NULL, *p7i;
    p7 = PKCS7_new();
    if (p7 == NULL) {
        PError(@"Error loading ca bundle: %@", name);
        [self openSSLError];
        return nil;
    }
    p7i = PEM_read_bio_PKCS7(pemBio, &p7, NULL, NULL);
    if (p7i == NULL) {
        PError(@"Error loading ca bundle: %@", name);
        [self openSSLError];
        return nil;
    }

    pemData = @"";
    BIO_free(pemBio);

    if (p7->d.sign == NULL) {
        PError(@"Error loading ca bundle: %@", name);
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
        return nil;
    }

    X509 *x;
    caStore = X509_STORE_new();

    for (i = 0; i < count; i++) {
        x = sk_X509_value(certs, i);
        if (!X509_STORE_add_cert(caStore, x)) {
            PError(@"Error adding certificate from bundle to store: %@", name);
            [self openSSLError];
            return nil;
        }
    }

    PDebug(@"Loaded %i certificates from bundle %@", count, name);
    return self;
}

- (BOOL) validateCertificates:(NSArray<CKCertificate *> *)certificates {
    if (caStore == NULL) {
        return false;
    }

    X509 * target = (X509 *)certificates[0].X509Certificate;
    PDebug(@"[MOZ] Target: %@", certificates[0].summary);
    STACK_OF(X509) * intermediates = sk_X509_new(NULL);
    for (int i = 1; i < certificates.count; i++) {
        CKCertificate * certificate = certificates[i];
        if (!certificate.isSelfSigned) {
            sk_X509_push(intermediates, (X509 *)certificate.X509Certificate);
            PDebug(@"[MOZ] Add: %@", certificate.summary);
        }
    }

    X509_STORE_CTX * ctx = X509_STORE_CTX_new();
    X509_STORE_CTX_init(ctx, caStore, target, intermediates);
    int verify = X509_STORE_CTX_verify(ctx);
    (void)verify;

    STACK_OF(X509) * chain = X509_build_chain(target, intermediates, caStore, 0, NULL, NULL);
    if (chain == NULL) {
        [self openSSLError];
    }
    return chain != NULL;
}

- (BOOL) containsCertificate:(CKCertificate *)certificate {
    if (caStore == NULL) {
        return false;
    }

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
