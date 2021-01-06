//
//  CKGetterParameters.h
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
 Possible options for the crypto engine used to chain getters
 */
typedef enum __CRYPTO_ENGINE {
    /**
     The modern Apple getter using the Network Framework
     */
    CRYPTO_ENGINE_NETWORK_FRAMEWORK = 0,
    /**
     The legacy Apple getter using SecureTransport
     */
    CRYPTO_ENGINE_SECURE_TRANSPORT = 1,
    /**
     The OpenSSL getter
     */
    CRYPTO_ENGINE_OPENSSL = 2,
} CRYPTO_ENGINE;

/**
 Possible options for IP versions
 */
typedef enum __IP_VERSIONS {
    /**
     Let the system choose which IP version to use
     */
    IP_VERSION_AUTOMATIC = 0,
    /**
     Prefer IPv4 connections
     */
    IP_VERSION_IPV4 = 1,
    /**
     Prefer IPv6 connections
     */
    IP_VERSION_IPV6 = 2,
} IP_VERSION;

@interface CKGetterParameters : NSObject

/**
 The URL to query
 */
@property (strong, nonatomic, nonnull) NSURL * queryURL;

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
 Which IP version should be used for the connection.
 */
@property (nonatomic) IP_VERSION ipVersion;

/**
 (OpenSSL only) The cipherstring used with OpenSSL
 */
@property (strong, nonatomic, nullable) NSString * ciphers;

@end

NS_ASSUME_NONNULL_END
