//
//  CKCertificateBundle.h
//
//  LGPLv3
//
//  Copyright (c) 2022 Ian Spence
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
#import "CKCertificateBundleMetadata.h"

NS_ASSUME_NONNULL_BEGIN

/// A root CA certificate bundle
@interface CKCertificateBundle : NSObject

/// Bundle metadata
@property (strong, nonatomic, readonly, nonnull) NSString * name;

/// Bundle metadata
@property (strong, nonatomic, readonly, nonnull) CKCertificateBundleMetadata * metadata;

/// If the bundle is embedded within the app
@property (nonatomic, readonly) BOOL embedded;

/// Create a new bundle with the given file path
/// - Parameters:
///   - filePath: A path pointing to a PKCS#7 archive of certificates
///   - name:     The name of this bundle
///   - metadata: The bundle metadata
- (CKCertificateBundle * _Nullable) initWithWithContentsOfFile:(NSString * _Nonnull)filePath name:(NSString * _Nonnull)name metadata:(CKCertificateBundleMetadata * _Nonnull)metadata;

/// Validate the chain of certificates using this bundle.
/// - Parameter certificates: The certificate chain, with the server/leaf certificate being index 0. If a root certificate is included, it is ignored.
- (BOOL) validateCertificates:(NSArray<CKCertificate *> * _Nonnull)certificates;

/// Does the bundle contains the given certificate
/// - Parameter certificate: the certificate
- (BOOL) containsCertificate:(CKCertificate * _Nonnull)certificate;

@end

NS_ASSUME_NONNULL_END
