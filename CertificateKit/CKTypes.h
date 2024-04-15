//
//  CKTypes.h
//  CertificateKit
//
//  Created by Ian Spence on 2021-04-05.
//  Copyright © 2021 Ian Spence. All rights reserved.
//

#ifndef CKTypes_h
#define CKTypes_h

/// Network engine enum values
typedef NS_ENUM(NSInteger, CKNetworkEngine) {
    /// The Apple Network Framework engine
    CKNetworkEngineNetworkFramework = 0,
    /// OpenSSL network engine
    CKNetworkEngineOpenSSL = 2,
};

/// IP Address versions or family
typedef NS_ENUM(NSInteger, CKIPAddressVersion) {
    /// Unspecified or automatic
    CKIPAddressVersionUnspecified = 0,
    /// IPv4
    CKIPAddressVersion4 = 4,
    /// IPv6
    CKIPAddressVersion6 = 6,
};

#endif /* CKTypes_h */
