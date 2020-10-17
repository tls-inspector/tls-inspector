//
//  CKGetterOptions.h
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
 Describes options for the CKGetter class
 */
@interface CKGetterOptions : NSObject

/**
 Should HTTP server information be collected for the domain
 */
@property (nonatomic) BOOL queryServerInfo;

/**
 Should the OCSP responder be checked for certificates in the chain
 */
@property (nonatomic) BOOL checkOCSP;

/**
 Should any CRLs be downloaded and checked
 */
@property (nonatomic) BOOL checkCRL;

@property (nonatomic) BOOL useOpenSSL;

@property (strong, nonatomic, nullable) NSString * ciphers;

@end
