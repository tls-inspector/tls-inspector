//
//  CKCertificateExtension.m
//
//  LGPLv3
//
//  Copyright (c) 2023 Ian Spence
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

#import "CKCertificateExtension.h"
#import "CKCertificateExtension+Private.h"

@interface CKCertificateExtension ()

@property (strong, nonatomic, nonnull, readwrite) NSString * oid;
@property (nonatomic, readwrite) BOOL critical;
@property (nonatomic, readwrite) CKCertificateExtensionValueType valueType;
@property (strong, nonatomic) NSObject * value;

@end

@implementation CKCertificateExtension

+ (CKCertificateExtension *) withOID:(NSString *)oid stringValue:(NSString *)stringVal critical:(BOOL)critical {
    CKCertificateExtension * extension = [CKCertificateExtension new];
    extension.valueType = CKCertificateExtensionValueTypeString;
    extension.oid = oid;
    extension.critical = critical;
    extension.value = stringVal;
    return extension;
}

+ (CKCertificateExtension *) withOID:(NSString *)oid numberValue:(NSNumber *)numberVal critical:(BOOL)critical {
    CKCertificateExtension * extension = [CKCertificateExtension new];
    extension.valueType = CKCertificateExtensionValueTypeNumber;
    extension.oid = oid;
    extension.critical = critical;
    extension.value = numberVal;
    return extension;
}

+ (CKCertificateExtension *) withOID:(NSString *)oid boolValue:(BOOL)boolVal critical:(BOOL)critical {
    CKCertificateExtension * extension = [CKCertificateExtension new];
    extension.valueType = CKCertificateExtensionValueTypeBoolean;
    extension.oid = oid;
    extension.critical = critical;
    extension.value = [NSNumber numberWithBool:boolVal];
    return extension;
}

+ (CKCertificateExtension *) withOID:(NSString *)oid dateValue:(NSDate *)dateVal critical:(BOOL)critical {
    CKCertificateExtension * extension = [CKCertificateExtension new];
    extension.valueType = CKCertificateExtensionValueTypeDate;
    extension.oid = oid;
    extension.critical = critical;
    extension.value = dateVal;
    return extension;
}

- (NSString *) stringValue {
    if (self.valueType != CKCertificateExtensionValueTypeString) {
        return nil;
    }

    return (NSString *)self.value;
}

- (BOOL) boolValue {
    if (self.valueType != CKCertificateExtensionValueTypeBoolean) {
        return false;
    }

    return ((NSNumber *)self.value).boolValue;
}

- (NSInteger) integerValue {
    if (self.valueType != CKCertificateExtensionValueTypeNumber) {
        return false;
    }

    return ((NSNumber *)self.value).integerValue;
}

- (NSDate *) dateValue {
    if (self.valueType != CKCertificateExtensionValueTypeDate) {
        return nil;
    }

    return (NSDate *)self.value;
}

- (NSString *) hexString {
    return (NSString *)self.value;
}

@end
