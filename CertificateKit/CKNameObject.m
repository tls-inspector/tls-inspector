//
//  CKNameObject.m
//
//  MIT License
//
//  Copyright (c) 2018 Ian Spence
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

#import "CKNameObject.h"
#include <openssl/x509.h>

@interface CKNameObject ()

@property (strong, nonatomic, nullable, readwrite) NSString * commonName;
@property (strong, nonatomic, nullable, readwrite) NSString * countryName;
@property (strong, nonatomic, nullable, readwrite) NSString * stateOrProvinceName;
@property (strong, nonatomic, nullable, readwrite) NSString * localityName;
@property (strong, nonatomic, nullable, readwrite) NSString * organizationName;
@property (strong, nonatomic, nullable, readwrite) NSString * organizationalUnitName;
@property (strong, nonatomic, nullable, readwrite) NSString * emailAddress;

@end

@implementation CKNameObject

+ (CKNameObject *) fromSubject:(void *)name {
    CKNameObject * object = [CKNameObject new];

    NSString * (^valueForNID)(int) = ^NSString *(int nid) {
        int idx = X509_NAME_get_index_by_NID((X509_NAME *)name, NID_commonName, -1);
        X509_NAME_ENTRY * entry = X509_NAME_get_entry((X509_NAME *)name, idx);
        if (entry == NULL) {
            return nil;
        }

        ASN1_STRING * data = X509_NAME_ENTRY_get_data(entry);
        if (data != NULL) {
            const unsigned char *issuerName = ASN1_STRING_get0_data(data);
            return [NSString stringWithUTF8String:(char *)issuerName];
        }

        return nil;
    };

    object.commonName = valueForNID(NID_commonName);
    object.countryName = valueForNID(NID_countryName);
    object.stateOrProvinceName = valueForNID(NID_stateOrProvinceName);
    object.localityName = valueForNID(NID_localityName);
    object.organizationName = valueForNID(NID_organizationName);
    object.organizationalUnitName = valueForNID(NID_organizationalUnitName);
    object.emailAddress = valueForNID(NID_pkcs9_emailAddress);

    return object;
}

@end
