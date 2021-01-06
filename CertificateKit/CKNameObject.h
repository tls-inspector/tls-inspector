//
//  CKNameObject.h
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

