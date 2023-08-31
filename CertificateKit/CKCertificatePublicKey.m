//
//  CKCertificatePublicKey.m
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

#import "CKCertificatePublicKey.h"
#import "CKCertificate+Private.h"
#include <openssl/x509.h>
#include <openssl/x509v3.h>

@interface CKCertificatePublicKey ()

@property (strong, nonatomic, readwrite) NSString * algroithm;
@property (nonatomic, readwrite) int bitLength;

@end

@implementation CKCertificatePublicKey

+ (CKCertificatePublicKey *) infoFromCertificate:(CKCertificate *)cert {
    X509_PUBKEY * pubkey = X509_get_X509_PUBKEY(cert.X509Certificate);
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

- (BOOL) isWeakRSA {
    return [[self.algroithm uppercaseString] isEqualToString:@"RSA"] && self.bitLength < 2048;
}

@end
