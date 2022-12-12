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

NS_ASSUME_NONNULL_BEGIN

/// A root CA certificate bundle
@interface CKCertificateBundle : NSObject

/// The date when the bundle was created
@property (strong, nonatomic, readonly, nullable) NSDate * bundleDate;

/// The SHA256 sum of the bundle file
@property (strong, nonatomic, readonly, nullable) NSString * bundleSHA256;

/// The number of certificates in the bundle
@property (strong, nonatomic, readonly, nullable) NSNumber * certificateCount;

/// If the bundle is embedded within the app
@property (nonatomic, readonly) BOOL embedded;

/// Create a new bundle with the given file path
/// - Parameters:
///   - filePath: A path pointing to a PKCS#7 archive of certificates
///   - metadata: A dictionary containing metadata about the bundle
- (CKCertificateBundle * _Nullable) initWithWithContentsOfFile:(NSString * _Nonnull)filePath metadata:(NSDictionary<NSString *, id> * _Nonnull)metadata;

/// Validate the chain of certificates using this bundle.
/// - Parameter certificates: The certificate chain, with the server/leaf certificate being index 0. If a root certificate is included, it is ignored.
- (BOOL) validateCertificates:(NSArray<CKCertificate *> * _Nonnull)certificates;

/// Does the bundle contains the given certificate
/// - Parameter certificate: the certificate
- (BOOL) containsCertificate:(CKCertificate * _Nonnull)certificate;

@end

NS_ASSUME_NONNULL_END
