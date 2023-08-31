//
//  CKNetworkFrameworkInspector+EnumValues.h
//
//  LGPLv3
//
//  Copyright (c) 2023 Ian Spence
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
#import "CKNetworkFrameworkInspector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CKNetworkFrameworkInspector (EnumValues)

- (NSString *) sslVersionToString:(SSLProtocol)version API_AVAILABLE(ios(12.0));
- (NSString *) tlsVersionToString:(tls_protocol_version_t)version API_AVAILABLE(ios(13.0));
- (NSString *) sslCipherSuiteToString:(SSLCipherSuite)suite API_AVAILABLE(ios(12.0));
- (NSString *) tlsCipherSuiteToString:(tls_ciphersuite_t)suite API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
