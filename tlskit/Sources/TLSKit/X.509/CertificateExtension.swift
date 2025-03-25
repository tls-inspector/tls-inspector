// TLSKit
// Copyright (C) 2025 Ian Spence
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

/// Describes a X.509 certificate extension
public struct CertificateExtension: Sendable, Equatable, Comparable {
    /// The ASN.1 object ID
    public let oid: String
    /// If this extension is marked as critical
    public let critical: Bool
    /// The value of the extension
    public let value: Data

    internal static func fromCertificate(_ cert: X509) -> [CertificateExtension]? {
        var extensions: [CertificateExtension] = []
        let extCount = X509_get_ext_count(cert)
        for i in 0..<extCount {
            if let ext = CertificateExtension.fromX509Ext(X509_get_ext(cert, i)) {
                extensions.append(ext)
            }
        }
        if extensions.isEmpty {
            return nil
        }
        return extensions
    }

    internal static func fromX509Ext(_ ext: OpaquePointer!) -> CertificateExtension? {
        guard let obj = X509_EXTENSION_get_object(ext) else {
            return nil
        }

        guard let oid = String.from(obj: obj, maxLength: 128, numerical: true) else {
            return nil
        }

        let critical = X509_EXTENSION_get_critical(ext)
        guard let value = X509_EXTENSION_get_data(ext) else {
            return nil
        }
        guard let data = Data.from(asn1OctetString: value) else {
            return nil
        }

        return CertificateExtension(oid: oid, critical: critical == 1, value: data)
    }

    public static func < (lhs: CertificateExtension, rhs: CertificateExtension) -> Bool {
        return lhs.oid < rhs.oid
    }
}
