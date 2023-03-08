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

/// Create a new bundle
/// - Parameters:
///   - name: Name of the bundle
///   - filePath: file path of the bundle
///   - metadata: metadata for the bundle
///   - errPtr: return error
+ (CKCertificateBundle * _Nullable) bundleWithName:(NSString * _Nonnull)name bundlePath:(NSString * _Nonnull)filePath metadata:(CKCertificateBundleMetadata * _Nonnull)metadata error:(NSError * _Nullable * _Nullable)errPtr;

/// Validate the chain of certificates using this bundle.
/// - Parameter certificates: The certificate chain, with the server/leaf certificate being index 0. If a root certificate is included, it is ignored.
- (BOOL) validateCertificates:(NSArray<CKCertificate *> * _Nonnull)certificates;

/// Does the bundle contains the given certificate
/// - Parameter certificate: the certificate
- (BOOL) containsCertificate:(CKCertificate * _Nonnull)certificate;

@end

NS_ASSUME_NONNULL_END
