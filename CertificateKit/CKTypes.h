//
//  CKTypes.h
//  CertificateKit
//
//  Created by Ian Spence on 2021-04-05.
//  Copyright © 2021 Ian Spence. All rights reserved.
//

#ifndef CKTypes_h
#define CKTypes_h

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

#endif /* CKTypes_h */
