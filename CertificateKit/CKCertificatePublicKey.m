#import "CKCertificatePublicKey.h"
#include <openssl/x509.h>
#include <openssl/x509v3.h>

@interface CKCertificatePublicKey ()

@property (strong, nonatomic, readwrite) NSString * algroithm;
@property (nonatomic, readwrite) int bitLength;

@end

@implementation CKCertificatePublicKey

+ (CKCertificatePublicKey *) infoFromCertificate:(CKCertificate *)cert {
    X509_PUBKEY * pubkey = X509_get_X509_PUBKEY((X509 *)cert.X509Certificate);
    X509_ALGOR * keyType;
    EVP_PKEY * ppkey = X509_PUBKEY_get0(pubkey);
    int bits = EVP_PKEY_bits(ppkey);
    int rv = X509_PUBKEY_get0_param(NULL, NULL, NULL, &keyType, pubkey);
    if (rv < 0) {
        return nil;
    }

    char buffer[128];
    OBJ_obj2txt(buffer, sizeof(buffer), keyType->algorithm, 0);
    NSString * alg = [NSString stringWithUTF8String:buffer];

    CKCertificatePublicKey * publicKeyInfo = [CKCertificatePublicKey new];
    publicKeyInfo.algroithm = alg;
    publicKeyInfo.bitLength = bits;
    return publicKeyInfo;
}

@end
