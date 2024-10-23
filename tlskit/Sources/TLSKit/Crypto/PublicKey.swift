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

/// Possible X.509 Public Key algorithms。
///
/// Other algorithms are technically supported, however baseline TLS requirements only permit RSA and ECDSA for now
public enum KeyAlgorithm: Sendable {
    case rsa
    case ecdsa
}

/// Describes a public key associated with a certificate
public struct PublicKey: Sendable {
    /// The algorithm of the public key
    public let algorithm: KeyAlgorithm
    /// The size of the public key
    public let size: Int32

    internal static func fromCertificate(_ x509: X509) throws -> PublicKey {
        guard let x509pubkey = X509_get_X509_PUBKEY(x509) else {
            throw MakeError("X509_get_X509_PUBKEY returned nil")
        }

        guard let pubkey = X509_PUBKEY_get0(x509pubkey) else {
            throw MakeError("X509_PUBKEY_get0 returned nil")
        }

        let size = EVP_PKEY_get_bits(pubkey)

        let oid = EVP_PKEY_get_id(pubkey)

        let algorithm: KeyAlgorithm
        if oid == NID_X9_62_id_ecPublicKey {
            algorithm = .ecdsa
        } else if oid == NID_rsaEncryption {
            algorithm = .rsa
        } else {
            throw MakeError("Unknown public key algorithm \(oid)")
        }

        return PublicKey(algorithm: algorithm, size: size)
    }
}
