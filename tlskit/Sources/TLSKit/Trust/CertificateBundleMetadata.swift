// TLSKit
// Copyright (C) 2024 Ian Spence
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import OpenSSL

/// Describes metadata about a certificate bundle
public struct CertificateBundleMetadata: Sendable {
    /// The date this bundle was created
    public let date: Date
    /// The SHA-256 digest of this bundle
    public let sha256: String
    /// The number of certificates in this bundle
    public let certificateCount: UInt

    internal init(date: Date, sha256: String, certificateCount: UInt) {
        self.date = date
        self.sha256 = sha256
        self.certificateCount = certificateCount
    }
}

internal struct RootCABundleMetadata: Codable {
    let mozilla: RootCABundleMetadataVendor
    let microsoft: RootCABundleMetadataVendor
    let google: RootCABundleMetadataVendor
    let apple: RootCABundleMetadataVendor
    let tlsinspector: RootCABundleMetadataVendor
}

internal struct RootCABundleMetadataVendor: Codable {
    let date: String
    let key: String
    let num_certs: UInt
    let bundles: [String: RootCABundleMetadataVendorAsset]
}

internal struct RootCABundleMetadataVendorAsset: Codable {
    let sha1: String
    let sha256: String
    let sha512: String
}
