//
//  CKRootCACertificateBundleManager.h
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
#import "CKCertificateBundle.h"

NS_ASSUME_NONNULL_BEGIN

/// The manager for the root CA certificate bundles
@interface CKRootCACertificateBundleManager : NSObject

/// The shared instance of the manager
+ (CKRootCACertificateBundleManager *) sharedInstance;

/// Check for newer versions of root CA certificate bundles
/// Returns: Any update error. Nil indicates newer bundles were downloaded. An error with code 200 means no updates were needed.
- (NSError * _Nullable) updateNow;

/// Clears any downloaded bundles and reloads using the embedded bundles
- (void) clearDownloadedBundles;

/// Is the manager using downloaded bundles
@property (nonatomic, readonly) BOOL usingDownloadedBundles;

/// The Apple root CA certificate bundle
@property (strong, nonatomic, readonly, nullable) CKCertificateBundle * appleBundle;

/// The Google root CA certificate bundle
@property (strong, nonatomic, readonly, nullable) CKCertificateBundle * googleBundle;

/// The Microsoft root CA certificate bundle
@property (strong, nonatomic, readonly, nullable) CKCertificateBundle * microsoftBundle;

/// The Mozilla root CA certificate bundle
@property (strong, nonatomic, readonly, nullable) CKCertificateBundle * mozillaBundle;

@end

NS_ASSUME_NONNULL_END
