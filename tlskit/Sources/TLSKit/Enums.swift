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

/// TLS Versions
public enum TLSVersion: Int, CaseIterable, Sendable {
    case v10 = 0
    case v11 = 1
    case v12 = 2
    case v13 = 3

    @available(iOS 13.0, *)
    internal static func from(tls_protocol_version_t: tls_protocol_version_t) -> TLSVersion? {
        switch tls_protocol_version_t {
        case .TLSv10:
            return .v10
        case .TLSv11:
            return .v11
        case .TLSv12:
            return .v12
        case .TLSv13:
            return .v13
        default:
            return nil
        }
    }

    internal static func from(SSLProtocol: SSLProtocol) -> TLSVersion? {
        switch SSLProtocol {
        case .tlsProtocol1:
            return .v10
        case .tlsProtocol11:
            return .v11
        case .tlsProtocol12:
            return .v12
        case .tlsProtocol13:
            return .v13
        default:
            return nil
        }
    }

    internal static func from(openssl version: Int32) -> TLSVersion? {
        switch version {
        case TLS1_VERSION:
            return .v10
        case TLS1_1_VERSION:
            return .v11
        case TLS1_2_VERSION:
            return .v12
        case TLS1_3_VERSION:
            return .v13
        default:
            return nil
        }
    }

    public func string() -> String {
        switch self {
        case .v10:
            return "TLS 1.0"
        case .v11:
            return "TLS 1.1"
        case .v12:
            return "TLS 1.2"
        case .v13:
            return "TLS 1.3"
        }
    }
}

/// TLS Ciphersuites
public enum Ciphersuite: Int, CaseIterable, Sendable {
    // swiftlint:disable identifier_name
    case RSA_WITH_3DES_EDE_CBC_SHA = 1
    case RSA_WITH_AES_128_CBC_SHA = 2
    case RSA_WITH_AES_256_CBC_SHA = 3
    case RSA_WITH_AES_128_GCM_SHA256 = 4
    case RSA_WITH_AES_256_GCM_SHA384 = 5
    case RSA_WITH_AES_128_CBC_SHA256 = 6
    case RSA_WITH_AES_256_CBC_SHA256 = 7
    case ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA = 8
    case ECDHE_ECDSA_WITH_AES_128_CBC_SHA = 9
    case ECDHE_ECDSA_WITH_AES_256_CBC_SHA = 10
    case ECDHE_RSA_WITH_3DES_EDE_CBC_SHA = 11
    case ECDHE_RSA_WITH_AES_128_CBC_SHA = 12
    case ECDHE_RSA_WITH_AES_256_CBC_SHA = 13
    case ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 = 14
    case ECDHE_ECDSA_WITH_AES_256_CBC_SHA384 = 15
    case ECDHE_RSA_WITH_AES_128_CBC_SHA256 = 16
    case ECDHE_RSA_WITH_AES_256_CBC_SHA384 = 17
    case ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 = 18
    case ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 = 19
    case ECDHE_RSA_WITH_AES_128_GCM_SHA256 = 20
    case ECDHE_RSA_WITH_AES_256_GCM_SHA384 = 21
    case ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256 = 22
    case ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256 = 23
    case AES_128_GCM_SHA256 = 24
    case AES_256_GCM_SHA384 = 25
    case CHACHA20_POLY1305_SHA256 = 26
    // swiftlint:enable identifier_name

    internal static func from(SSL_CIPHER: OpaquePointer) -> Ciphersuite? {
        guard let rawName = SSL_CIPHER_standard_name(SSL_CIPHER) else {
            return nil
        }
        let name = String(cString: rawName)

        switch name {
        case TLS1_RFC_ECDHE_RSA_WITH_DES_192_CBC3_SHA:
            return .RSA_WITH_3DES_EDE_CBC_SHA
        case TLS1_RFC_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return .RSA_WITH_AES_128_CBC_SHA
        case TLS1_RFC_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return .RSA_WITH_AES_256_CBC_SHA
        case TLS1_RFC_RSA_WITH_AES_128_GCM_SHA256:
            return .RSA_WITH_AES_128_GCM_SHA256
        case TLS1_RFC_RSA_WITH_AES_256_GCM_SHA384:
            return .RSA_WITH_AES_256_GCM_SHA384
        case TLS1_RFC_ECDHE_RSA_WITH_AES_128_SHA256:
            return .RSA_WITH_AES_128_CBC_SHA256
        case TLS1_RFC_ECDHE_RSA_WITH_AES_256_SHA384:
            return .RSA_WITH_AES_256_CBC_SHA256
        case TLS1_RFC_ECDHE_ECDSA_WITH_DES_192_CBC3_SHA:
            return .ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA
        case TLS1_RFC_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return .ECDHE_ECDSA_WITH_AES_128_CBC_SHA
        case TLS1_RFC_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return .ECDHE_ECDSA_WITH_AES_256_CBC_SHA
        case TLS1_RFC_ECDHE_RSA_WITH_DES_192_CBC3_SHA:
            return .ECDHE_RSA_WITH_3DES_EDE_CBC_SHA
        case TLS1_RFC_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return .ECDHE_RSA_WITH_AES_128_CBC_SHA
        case TLS1_RFC_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return .ECDHE_RSA_WITH_AES_256_CBC_SHA
        case TLS1_RFC_ECDHE_ECDSA_WITH_AES_128_SHA256:
            return .ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
        case TLS1_RFC_ECDHE_ECDSA_WITH_AES_256_SHA384:
            return .ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
        case TLS1_RFC_ECDHE_RSA_WITH_AES_128_SHA256:
            return .ECDHE_RSA_WITH_AES_128_CBC_SHA256
        case TLS1_RFC_ECDHE_RSA_WITH_AES_256_SHA384:
            return .ECDHE_RSA_WITH_AES_256_CBC_SHA384
        case TLS1_RFC_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return .ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        case TLS1_RFC_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return .ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        case TLS1_RFC_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return .ECDHE_RSA_WITH_AES_128_GCM_SHA256
        case TLS1_RFC_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return .ECDHE_RSA_WITH_AES_256_GCM_SHA384
        case TLS1_RFC_ECDHE_RSA_WITH_CHACHA20_POLY1305:
            return .ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
        case TLS1_RFC_ECDHE_ECDSA_WITH_CHACHA20_POLY1305:
            return .ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        case TLS1_3_RFC_AES_128_GCM_SHA256:
            return .AES_128_GCM_SHA256
        case TLS1_3_RFC_AES_256_GCM_SHA384:
            return .AES_256_GCM_SHA384
        case TLS1_3_RFC_CHACHA20_POLY1305_SHA256:
            return .CHACHA20_POLY1305_SHA256
        default:
            printError("[\(#fileID):\(#line)] Unknown ciphersuite: \(name)")
            return nil
        }
    }

    internal static func from(SSLCipherSuite: SSLCipherSuite) -> Ciphersuite? {
        switch SSLCipherSuite {
        case TLS_RSA_WITH_3DES_EDE_CBC_SHA:
            return .RSA_WITH_3DES_EDE_CBC_SHA
        case TLS_RSA_WITH_AES_128_CBC_SHA:
            return .RSA_WITH_AES_128_CBC_SHA
        case TLS_RSA_WITH_AES_256_CBC_SHA:
            return .RSA_WITH_AES_256_CBC_SHA
        case TLS_RSA_WITH_AES_128_GCM_SHA256:
            return .RSA_WITH_AES_128_GCM_SHA256
        case TLS_RSA_WITH_AES_256_GCM_SHA384:
            return .RSA_WITH_AES_256_GCM_SHA384
        case TLS_RSA_WITH_AES_128_CBC_SHA256:
            return .RSA_WITH_AES_128_CBC_SHA256
        case TLS_RSA_WITH_AES_256_CBC_SHA256:
            return .RSA_WITH_AES_256_CBC_SHA256
        case TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return .ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return .ECDHE_ECDSA_WITH_AES_128_CBC_SHA
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return .ECDHE_ECDSA_WITH_AES_256_CBC_SHA
        case TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return .ECDHE_RSA_WITH_3DES_EDE_CBC_SHA
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return .ECDHE_RSA_WITH_AES_128_CBC_SHA
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return .ECDHE_RSA_WITH_AES_256_CBC_SHA
        case TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return .ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
        case TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return .ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
        case TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return .ECDHE_RSA_WITH_AES_128_CBC_SHA256
        case TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return .ECDHE_RSA_WITH_AES_256_CBC_SHA384
        case TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return .ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        case TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return .ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        case TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return .ECDHE_RSA_WITH_AES_128_GCM_SHA256
        case TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return .ECDHE_RSA_WITH_AES_256_GCM_SHA384
        case TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:
            return .ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
        case TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:
            return .ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        case TLS_AES_128_GCM_SHA256:
            return .AES_128_GCM_SHA256
        case TLS_AES_256_GCM_SHA384:
            return .AES_256_GCM_SHA384
        case TLS_CHACHA20_POLY1305_SHA256:
            return .CHACHA20_POLY1305_SHA256
        default:
            return nil
        }
    }

    internal static func from(tls_ciphersuite_t: tls_ciphersuite_t) -> Ciphersuite? {
        switch tls_ciphersuite_t {
        case .RSA_WITH_3DES_EDE_CBC_SHA:
            return .RSA_WITH_3DES_EDE_CBC_SHA
        case .RSA_WITH_AES_128_CBC_SHA:
            return .RSA_WITH_AES_128_CBC_SHA
        case .RSA_WITH_AES_256_CBC_SHA:
            return .RSA_WITH_AES_256_CBC_SHA
        case .RSA_WITH_AES_128_GCM_SHA256:
            return .RSA_WITH_AES_128_GCM_SHA256
        case .RSA_WITH_AES_256_GCM_SHA384:
            return .RSA_WITH_AES_256_GCM_SHA384
        case .RSA_WITH_AES_128_CBC_SHA256:
            return .RSA_WITH_AES_128_CBC_SHA256
        case .RSA_WITH_AES_256_CBC_SHA256:
            return .RSA_WITH_AES_256_CBC_SHA256
        case .ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA:
            return .ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA
        case .ECDHE_ECDSA_WITH_AES_128_CBC_SHA:
            return .ECDHE_ECDSA_WITH_AES_128_CBC_SHA
        case .ECDHE_ECDSA_WITH_AES_256_CBC_SHA:
            return .ECDHE_ECDSA_WITH_AES_256_CBC_SHA
        case .ECDHE_RSA_WITH_3DES_EDE_CBC_SHA:
            return .ECDHE_RSA_WITH_3DES_EDE_CBC_SHA
        case .ECDHE_RSA_WITH_AES_128_CBC_SHA:
            return .ECDHE_RSA_WITH_AES_128_CBC_SHA
        case .ECDHE_RSA_WITH_AES_256_CBC_SHA:
            return .ECDHE_RSA_WITH_AES_256_CBC_SHA
        case .ECDHE_ECDSA_WITH_AES_128_CBC_SHA256:
            return .ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
        case .ECDHE_ECDSA_WITH_AES_256_CBC_SHA384:
            return .ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
        case .ECDHE_RSA_WITH_AES_128_CBC_SHA256:
            return .ECDHE_RSA_WITH_AES_128_CBC_SHA256
        case .ECDHE_RSA_WITH_AES_256_CBC_SHA384:
            return .ECDHE_RSA_WITH_AES_256_CBC_SHA384
        case .ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:
            return .ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        case .ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:
            return .ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        case .ECDHE_RSA_WITH_AES_128_GCM_SHA256:
            return .ECDHE_RSA_WITH_AES_128_GCM_SHA256
        case .ECDHE_RSA_WITH_AES_256_GCM_SHA384:
            return .ECDHE_RSA_WITH_AES_256_GCM_SHA384
        case .ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:
            return .ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
        case .ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:
            return .ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        case .AES_128_GCM_SHA256:
            return .AES_128_GCM_SHA256
        case .AES_256_GCM_SHA384:
            return .AES_256_GCM_SHA384
        case .CHACHA20_POLY1305_SHA256:
            return .CHACHA20_POLY1305_SHA256
        default:
            return nil
        }
    }

    public func string() -> String {
        return String(describing: self)
    }
}

/// Signature Algorithms
public enum SignatureAlgorithm: Sendable {
    // swiftlint:disable identifier_name
    case RSA_SHA224
    case RSA_SHA256
    case RSA_SHA384
    case RSA_SHA512
    case ECDSA_SHA224
    case ECDSA_SHA256
    case ECDSA_SHA384
    case ECDSA_SHA512
    case Unknown
    // swiftlint:enable identifier_name

    public func string() -> String {
        switch self {
        case .RSA_SHA224:
            return "RSA with SHA-224"
        case .RSA_SHA256:
            return "RSA with SHA-256"
        case .RSA_SHA384:
            return "RSA with SHA-384"
        case .RSA_SHA512:
            return "RSA with SHA-512"
        case .ECDSA_SHA224:
            return "ECDSA with SHA-224"
        case .ECDSA_SHA256:
            return "ECDSA with SHA-256"
        case .ECDSA_SHA384:
            return "ECDSA with SHA-384"
        case .ECDSA_SHA512:
            return "ECDSA with SHA-512"
        case .Unknown:
            return "Unknown"
        }
    }

    internal static func from(nid: Int32) -> SignatureAlgorithm {
        switch nid {
        case NID_sha224WithRSAEncryption:
            return .RSA_SHA224
        case NID_sha256WithRSAEncryption:
            return .RSA_SHA256
        case NID_sha384WithRSAEncryption:
            return .RSA_SHA384
        case NID_sha512WithRSAEncryption:
            return .RSA_SHA512
        case NID_ecdsa_with_SHA224:
            return .ECDSA_SHA224
        case NID_ecdsa_with_SHA256:
            return .ECDSA_SHA256
        case NID_ecdsa_with_SHA384:
            return .ECDSA_SHA384
        case NID_ecdsa_with_SHA512:
            return .ECDSA_SHA512
        default:
            return .Unknown
        }
    }
}
