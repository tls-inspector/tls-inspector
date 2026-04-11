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

/// Describes both basic and extended key usage scenarios for a certificate
public struct KeyUsage: Sendable {
    /// A basic key usage type
    public let basic: [BasicKeyUsage]?
    /// An extended key usage type
    public let extended: [ExtendedKeyUsage]?

    internal static func fromCertificate(_ x509: X509) -> KeyUsage? {
        var basicKeyUsage: [BasicKeyUsage]?
        var extendedKeyUsage: [ExtendedKeyUsage]?

        if let basic = BasicKeyUsage.fromCertificate(x509) {
            basicKeyUsage = []
            for ku in basic {
                basicKeyUsage?.append(ku)
            }
        }

        if let extended = ExtendedKeyUsage.fromCertificate(x509) {
            extendedKeyUsage = []
            for ku in extended {
                extendedKeyUsage?.append(ku)
            }
        }

        if basicKeyUsage == nil && extendedKeyUsage == nil {
            return nil
        }

        return KeyUsage(basic: basicKeyUsage, extended: extendedKeyUsage)
    }
}

/// Describes possible basic key usage types
public enum BasicKeyUsage: String, CaseIterable, Sendable {
    case digitalSignature
    case nonRepudiation
    case keyEncipherment
    case dataEncipherment
    case keyAgreement
    case keyCertSign
    case cRLSign
    case encipherOnly
    case decipherOnly

    internal static func fromCertificate(_ x509: X509) -> [BasicKeyUsage]? {
        guard let keyUsage = X509_get_ext_d2i(x509, NID_key_usage, nil, nil)?.assumingMemoryBound(to: ASN1_BIT_STRING.self) else {
            return nil
        }

        var values: [BasicKeyUsage] = []

        for i in 0..<BasicKeyUsage.allCases.count where ASN1_BIT_STRING_get_bit(keyUsage, Int32(i)) != 0  {
            values.append(BasicKeyUsage.allCases[i])
        }

        return values
    }
}

/// Describes possible extended key usage types
public enum ExtendedKeyUsage: String, Sendable {
    case serverAuth
    case clientAuth
    case emailProtection
    case codeSigning
    case oCSPSigning
    case timeStamping
    case unknown

    internal static func fromCertificate(_ x509: X509) -> [ExtendedKeyUsage]? {
        var values: [ExtendedKeyUsage] = []

        guard let ekuRaw = X509_get_ext_d2i(x509, NID_ext_key_usage, nil, nil) else {
            return nil
        }
        let eku = OpaquePointer(ekuRaw)

        for i in 0..<OPENSSL_sk_num(eku) {
            guard let value = OPENSSL_sk_value(eku, i) else {
                return nil
            }
            let usage = OBJ_obj2nid(OpaquePointer(value))
            switch usage {
            case NID_server_auth:
                values.append(.serverAuth)
            case NID_client_auth:
                values.append(.clientAuth)
            case NID_email_protect:
                values.append(.emailProtection)
            case NID_code_sign:
                values.append(.codeSigning)
            case NID_OCSP_sign:
                values.append(.oCSPSigning)
            case NID_time_stamp:
                values.append(.timeStamping)
            default:
                values.append(.unknown)
            }
        }

        return values
    }
}
