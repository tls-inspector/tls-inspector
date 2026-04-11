// TLSKit
// Copyright (C) Ian Spence and other TLSKit Contributors
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
import Curl

/// Describes a library version
public struct LibraryVersion {
    /// The major version number
    public let major: Int32
    /// The minor version number
    public let minor: Int32
    /// The patch version number
    public let patch: Int32

    /// The version represented as a string
    public var string: String {
        return "\(major).\(minor).\(patch)"
    }
}

/// Utilities for getting library versions
public struct Versions {
    /// The OpenSSL library version
    public static var openssl: LibraryVersion {
        return LibraryVersion(major: OPENSSL_VERSION_MAJOR, minor: OPENSSL_VERSION_MINOR, patch: OPENSSL_VERSION_PATCH)
    }

    /// The Curl library version
    public static var curl: LibraryVersion {
        return LibraryVersion(major: LIBCURL_VERSION_MAJOR, minor: LIBCURL_VERSION_MINOR, patch: LIBCURL_VERSION_PATCH)
    }
}
