//
//  CKCertificateExtension.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CKCertificateExtensionValueType) {
    CKCertificateExtensionValueTypeBoolean = 0,
    CKCertificateExtensionValueTypeNumber = 1,
    CKCertificateExtensionValueTypeString = 2,
    CKCertificateExtensionValueTypeDate = 3,
    CKCertificateExtensionValueTypeUnknown = 4,
};

@interface CKCertificateExtension : NSObject

/// The object ID (OID) in numerical form represented as a period-joined string (example: 1.2.3.4)
@property (strong, nonatomic, nonnull, readonly) NSString * oid;

/// The type of value for this extension.
@property (nonatomic, readonly) CKCertificateExtensionValueType valueType;

/// If this extension is critical, meaning that the client must be able to parse it.
/// CertificateKit doesn't follow this rule.
@property (nonatomic, readonly) BOOL critical;

/// The string value for this extension, if this extension is a string type.
- (NSString * _Nullable) stringValue;

/// The boolean value for this extension, if this extension is a boolean type.
- (BOOL) boolValue;

/// The integer value for this extension, if this extension is a number type.
- (NSInteger) integerValue;

/// The date value for this extension, if this extension is a date type.
- (NSDate * _Nullable) dateValue;

/// A hex representation of the extensions value.
- (NSString *) hexString;

@end

NS_ASSUME_NONNULL_END
