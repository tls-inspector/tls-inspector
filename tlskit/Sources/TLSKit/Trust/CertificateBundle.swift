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

private typealias X509_STORE = OpaquePointer

/// Describes a bundle of certificates used as anchor certificates in chain validation
public struct CertificateBundle: Sendable {
    /// The name of this bundle
    public let name: String
    /// Metadata about this bundle
    public let metadata: CertificateBundleMetadata
    /// The number of certificates in the store
    public let certificateCount: UInt

    internal let bundlePath: URL
    internal let keyIdMap: [String: Int]
    internal let subjectMap: [String: Int]
    nonisolated(unsafe) private let store: X509_STORE!

    private init(name: String, metadata: CertificateBundleMetadata, certificateCount: UInt, bundlePath: URL, keyIdMap: [String : Int], subjectMap: [String : Int], store: X509_STORE!) {
        self.name = name
        self.metadata = metadata
        self.certificateCount = certificateCount
        self.bundlePath = bundlePath
        self.keyIdMap = keyIdMap
        self.subjectMap = subjectMap
        self.store = store
    }

    internal static func from(_ bundlePath: URL, name: String, metadata: CertificateBundleMetadata) throws -> CertificateBundle {
        guard let store = X509_STORE_new() else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_STORE_new returned nil")
            throw TLSKitError.internalError("Unable to load bundle")
        }

        guard let bio = BIO_new_file(bundlePath.path, "r") else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_new_file returned nil")
            throw TLSKitError.internalError("Unable to load bundle")
        }

        guard let skX509Info = PEM_X509_INFO_read_bio(bio, nil, nil, nil) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] PEM_X509_INFO_read_bio returned nil")
            throw TLSKitError.internalError("Unable to load bundle")
        }

        var keyIdMap: [String: Int] = [:]
        var subjectMap: [String: Int] = [:]
        var count: UInt = 0

        let certCount = OPENSSL_sk_num(skX509Info)
        for i in 0..<certCount {
            guard let x509Info = OPENSSL_sk_value(skX509Info, i)?.assumingMemoryBound(to: X509_INFO.self) else {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] OPENSSL_sk_value returned nil")
                throw TLSKitError.internalError("Unable to load bundle")
            }

            guard let x509 = x509Info.pointee.x509 else {
                printWarning("[\(#fileID):\(#line)] Non X509 certificate value found in certificate bundle at index \(i)")
                continue
            }

            if let rawSubjectId = X509_get_ext_d2i(x509, NID_subject_key_identifier, nil, nil)?.assumingMemoryBound(to: ASN1_OCTET_STRING.self), let subjectId = Data.from(asn1OctetString: rawSubjectId)?.hexEncodedString() {
                keyIdMap[subjectId] = Int(i)
            }

            if let subjectName = X509_NAME_oneline(X509_get_subject_name(x509), nil, 0) {
                let subject = String(cString: subjectName)

                subjectMap[subject] = Int(i)
            }

            count += 1
        }

        if count != metadata.certificateCount {
            printError("[\(#fileID):\(#line)] Certificate count from metadata did not match number of certificates imported from bundle. Expected \(metadata.certificateCount) got \(count)")
        }

        return CertificateBundle(name: name, metadata: metadata, certificateCount: count, bundlePath: bundlePath, keyIdMap: keyIdMap, subjectMap: subjectMap, store: store)
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
