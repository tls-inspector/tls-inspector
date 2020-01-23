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

@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * commonNames;
@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * countryCodes;
@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * states;
@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * cities;
@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * organizations;
@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * organizationalUnits;
@property (strong, nonatomic, nonnull, readwrite) NSArray<NSString *> * emailAddresses;

@end

@implementation CKNameObject

+ (CKNameObject *) fromSubject:(void *)name {
    CKNameObject * object = [CKNameObject new];
    
    NSMutableArray<NSString *> * commonNames = [NSMutableArray new];
    NSMutableArray<NSString *> * countryCodes = [NSMutableArray new];
    NSMutableArray<NSString *> * states = [NSMutableArray new];
    NSMutableArray<NSString *> * cities = [NSMutableArray new];
    NSMutableArray<NSString *> * organizations = [NSMutableArray new];
    NSMutableArray<NSString *> * organizationalUnits = [NSMutableArray new];
    NSMutableArray<NSString *> * emailAddresses = [NSMutableArray new];
    
    [CKNameObject name:(X509_NAME *)name nid:NID_commonName lastPos:-1 values:commonNames];
    [CKNameObject name:(X509_NAME *)name nid:NID_countryName lastPos:-1 values:countryCodes];
    [CKNameObject name:(X509_NAME *)name nid:NID_stateOrProvinceName lastPos:-1 values:states];
    [CKNameObject name:(X509_NAME *)name nid:NID_localityName lastPos:-1 values:cities];
    [CKNameObject name:(X509_NAME *)name nid:NID_organizationName lastPos:-1 values:organizations];
    [CKNameObject name:(X509_NAME *)name nid:NID_organizationalUnitName lastPos:-1 values:organizationalUnits];
    [CKNameObject name:(X509_NAME *)name nid:NID_pkcs9_emailAddress lastPos:-1 values:emailAddresses];

    object.commonNames = commonNames;
    object.countryCodes = countryCodes;
    object.states = states;
    object.cities = cities;
    object.organizations = organizations;
    object.organizationalUnits = organizationalUnits;
    object.emailAddresses = emailAddresses;

    return object;
}

+ (void) name:(X509_NAME *)name nid:(int)nid lastPos:(int)lastPos values:(NSMutableArray<NSString *> *)values {
    int idx = X509_NAME_get_index_by_NID((X509_NAME *)name, nid, lastPos);
    if (idx < 0) {
        return;
    }
    X509_NAME_ENTRY * entry = X509_NAME_get_entry((X509_NAME *)name, idx);
    if (entry == NULL) {
        return;
    }
    
    ASN1_STRING * data = X509_NAME_ENTRY_get_data(entry);
    if (data != NULL) {
        [values addObject:[NSString stringWithUTF8String:(char *)ASN1_STRING_get0_data(data)]];
        [CKNameObject name:name nid:nid lastPos:idx values:values];
    }
}

@end
