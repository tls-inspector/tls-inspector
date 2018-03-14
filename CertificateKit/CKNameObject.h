//
//  CKNameObject.h
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

#import <Foundation/Foundation.h>

/**
 Describes a X.509 name object
 */
@interface CKNameObject : NSObject

/**
 Generate a certificate subject object from the X509 name

 @param name The X509 name object
 @return A popuated name object
 */
+ (CKNameObject * _Nonnull) fromSubject:(void * _Nonnull)name;

/**
 The common name of the name.
 */
@property (strong, nonatomic, nullable, readonly) NSString * commonName;
/**
 The ISO 3166 2-letter country code for the name.
 */
@property (strong, nonatomic, nullable, readonly) NSString * countryName;
/**
 The state or province for the name.
 */
@property (strong, nonatomic, nullable, readonly) NSString * stateOrProvinceName;
/**
 The city name for the name.
 */
@property (strong, nonatomic, nullable, readonly) NSString * localityName;
/**
 The organization name for the name.
 */
@property (strong, nonatomic, nullable, readonly) NSString * organizationName;
/**
 The organizational unit (department) for the name.
 */
@property (strong, nonatomic, nullable, readonly) NSString * organizationalUnitName;
/**
 The PKCS9 Email Address for the name. Non-standard.
 */
@property (strong, nonatomic, nullable, readonly) NSString * emailAddress;

@end

