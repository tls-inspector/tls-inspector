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

/// Describes a TLS connection
public struct TLSConnection: Sendable {
    /// The domain of the server
    public let domain: String
    /// The remote address of the server
    public let remoteAddress: IPAddress
    /// The certificate chain from least to most specific
    public let certificates: [Certificate]
    /// The TLS version used
    public let version: TLSVersion
    /// The ciphersuite used
    public let ciphersuite: Ciphersuite
    /// Trust information
    public let trust: TrustStatus
    /// Signed certificate timestamps included in the TLS connection.
    /// Only supported with the OpenSSL engine.
    public let signedTimestamps: [SignedCertificateTimestamp]?
}
