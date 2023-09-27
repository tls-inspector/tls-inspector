//
//  CKTypes.h
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
