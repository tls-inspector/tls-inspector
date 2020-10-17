//
//  CKNameObject.m
//
//  LGPLv3
//
//  Copyright (c) 2018 Ian Spence
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
