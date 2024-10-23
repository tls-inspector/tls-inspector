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

fileprivate typealias X509_STORE = OpaquePointer

/// Describes a bundle of certificates used as anchor certificates in chain validation
public struct CertificateBundle: Sendable {
    /// The name of this bundle
    public let name: String
    /// Metadata about this bundle
    public let metadata: CertificateBundleMetadata

    internal let bundlePath: URL
    internal let keyIdMap: [String: Int]
    internal let subjectMap: [String: Int]
    nonisolated(unsafe) fileprivate let store: X509_STORE!

    fileprivate init(name: String, metadata: CertificateBundleMetadata, bundlePath: URL, keyIdMap: [String : Int], subjectMap: [String : Int], store: X509_STORE!) {
        self.name = name
        self.metadata = metadata
        self.bundlePath = bundlePath
        self.keyIdMap = keyIdMap
        self.subjectMap = subjectMap
        self.store = store
    }

    internal static func from(_ bundlePath: URL, name: String, metadata: CertificateBundleMetadata) throws -> CertificateBundle {
        guard let store = X509_STORE_new() else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_STORE_new returned nil")
            throw MakeError("Internal Error")
        }

        if X509_STORE_load_path(store, bundlePath.path) <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_STORE_load_path returned nil")
            throw MakeError("Internal Error")
        }

        guard let certs = X509_STORE_get1_all_certs(store) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_STORE_get1_all_certs returned nil")
            throw MakeError("Internal Error")
        }

        let certCount = OPENSSL_sk_num(certs)
        if UInt(certCount) != metadata.certificateCount {
            printError("[\(#fileID):\(#line)] Unexpected number of certificates loaded into store. Expected \(metadata.certificateCount), got \(certCount)")
            throw MakeError("Internal Error")
        }

        var keyIdMap: [String: Int] = [:]
        var subjectMap: [String: Int] = [:]

        for i in 0..<certCount {
            guard let x509 = OpaquePointer(OPENSSL_sk_value(certs, i)) else {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] OPENSSL_sk_value returned nil")
                throw MakeError("Internal Error")
            }

            if let rawSubjectId = X509_get_ext_d2i(x509, NID_subject_key_identifier, nil, nil)?.assumingMemoryBound(to: ASN1_OCTET_STRING.self), let subjectId = Data.from(asn1OctetString: rawSubjectId)?.hexEncodedString() {
                keyIdMap[subjectId] = Int(i)
            }

            if let subjectName = X509_NAME_oneline(X509_get_subject_name(x509), nil, 0) {
                let subject = String(cString: subjectName)

                subjectMap[subject] = Int(i)
            }
        }

        return CertificateBundle(name: name, metadata: metadata, bundlePath: bundlePath, keyIdMap: keyIdMap, subjectMap: subjectMap, store: store)
    }

    /// Does this certificate bundle include the given certificate, or a cross-signed certificate with the same key
    /// - Parameter certificate: The certificate
    /// - Returns: True if this bundle contains this certificate, or a certificate that was cross-signed with the same key
    public func includes(_ certificate: Certificate) -> Bool {
        return false
    }

    /// If this bundle was embedded in TLSKit or not
    public func embedded() -> Bool {
        return !self.bundlePath.path.contains("rootca")
    }
}
