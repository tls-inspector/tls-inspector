//
//  CKCertificatePublicKey.m
//
//  MIT License
//
//  Copyright (c) 2017 Ian Spence
//  https://tlsinspector.com/github.html
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

- (BOOL) isWeakRSA {
    return [[self.algroithm uppercaseString] isEqualToString:@"RSA"] && self.bitLength < 2048;
}

@end
