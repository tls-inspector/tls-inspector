//
//  CKTypes.h
//  CertificateKit
//
//  Created by Ian Spence on 2021-04-05.
//  Copyright © 2021 Ian Spence. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Supported network engines for inspection requests
 */
typedef NS_ENUM(NSUInteger, CKNetworkEngine) {
    /**
     The modern Apple engine using the Network Framework
     */
    CKNetworkEngineNetworkFramework = 0,
    /**
     The legacy Apple engine using SecureTransport
     */
    CKNetworkEngineSecureTransport = 1,
    /**
     The OpenSSL engine
     */
    CKNetworkEngineOpenSSL = 2,
};

/**
 Possible options for IP versions
 */
typedef NS_ENUM(NSUInteger, CKIPVersion) {
    /**
     Let the system choose which IP version to use
     */
    CKIPVersionAutomatic = 0,
    /**
     Prefer IPv4 connections
     */
    CKIPVersionIPv4 = 1,
    /**
     Prefer IPv6 connections
     */
    CKIPVersionIPv6 = 2,
};

#endif /* CKTypes_h */
