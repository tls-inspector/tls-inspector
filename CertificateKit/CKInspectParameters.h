//
//  CKInspectParameters.h
//
//  LGPLv3
//
//  Copyright (c) 2021 Ian Spence
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

/**
 User-specified parameters that describe what we should inspect and how.
 Values may need to be modified before they can be used.
 */
@interface CKInspectParameters : NSObject

/**
 The host address. Can be either a domain name or an IP address. If the ipAddress property is nil, will connect to this address.
 */
@property (strong, nonatomic, nonnull) NSString * hostAddress;

/**
 The port to connect to. If 0 will use 443.
 */
@property (nonatomic) UInt16 port;

/**
 The IP address of the host to connect to. If null, will use queryURL.
 */
@property (strong, nonatomic, nullable) NSString * ipAddress;

/**
 Should HTTP server information be collected for the domain.
 */
@property (nonatomic) BOOL queryServerInfo;

/**
 Should the OCSP responder be checked for certificates in the chain.
 */
@property (nonatomic) BOOL checkOCSP;

/**
 Should any CRLs be downloaded and checked.
 */
@property (nonatomic) BOOL checkCRL;

/**
 The engine used to fetch certificates.
 */
@property (nonatomic) CRYPTO_ENGINE cryptoEngine;

/**
 The engine used to fetch certificates (now in string form!)
 */
@property (strong, nonatomic, nonnull) NSString * cryptoEngineString;

/**
 Which IP version should be used for the connection.
 */
@property (nonatomic) IP_VERSION ipVersion;

/**
 Which IP version should be used for the connection (now in string form!)
 */
@property (strong, nonatomic, nonnull) NSString * ipVersionString;

/**
 (OpenSSL only) The cipherstring used with OpenSSL
 */
@property (strong, nonatomic, nullable) NSString * ciphers;

/**
 Compare this instance of CKGetterParameters with the provided other.
 */
- (BOOL) isEqual:(CKInspectParameters * _Nullable)other;

/**
 Return a dictionary representation of these parameters.
 */
- (NSDictionary<NSString *, id> *) dictionaryValue;

/**
 Parse the given dictionary into a parameters object. Will return nil if any values are missing or incorrect.
 */
+ (CKInspectParameters * _Nullable) fromDictionary:(NSDictionary<NSString *, id> * _Nonnull)d;

@end

NS_ASSUME_NONNULL_END
