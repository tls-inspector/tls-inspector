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
 All common names in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * commonNames;

/**
 All 2-letter country codes in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * countryCodes;

/**
 All states (provinces) in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * states;

/**
 All cities (localities) in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * cities;

/**
 All organization names in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * organizations;

/**
 All organization unit names in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * organizationalUnits;

/**
 All PKCS#9 Email-Addresses in this name object
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<NSString *> * emailAddresses;

@end

