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

/// Sources for certificate bundles
public enum BundleProvider: Sendable, CaseIterable {
    case apple
    case google
    case microsoft
    case mozilla
    case tlsInspector
}

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
    internal let certs: [Data]

    private init(name: String, metadata: CertificateBundleMetadata, certificateCount: UInt, bundlePath: URL, keyIdMap: [String : Int], subjectMap: [String : Int], certs: [Data]) {
        self.name = name
        self.metadata = metadata
        self.certificateCount = certificateCount
        self.bundlePath = bundlePath
        self.keyIdMap = keyIdMap
        self.subjectMap = subjectMap
        self.certs = certs
    }

    internal static func from(_ bundlePath: URL, name: String, metadata: CertificateBundleMetadata) throws -> CertificateBundle {
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

        var certs: [Data] = []
        var keyIdMap: [String: Int] = [:]
        var subjectMap: [String: Int] = [:]

        let certCount = OPENSSL_sk_num(skX509Info)
        for i in 0..<certCount {
            guard let x509Info = OPENSSL_sk_value(skX509Info, i)?.assumingMemoryBound(to: X509_INFO.self) else {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] OPENSSL_sk_value returned nil")
                throw TLSKitError.internalError("Unable to load bundle")
            }

            guard let x509 = x509Info.pointee.x509 else {
                printError("[\(#fileID):\(#line)] Non X509 certificate value found in certificate bundle at index \(i)")
                throw TLSKitError.internalError("Unable to load bundle")
            }
            guard let cert = I2D.X509(x509) else {
                printError("[\(#fileID):\(#line)] Unable to serialize x509")
                throw TLSKitError.internalError("Unable to load bundle")
            }
            certs.append(cert)

            if let rawSubjectId = X509_get_ext_d2i(x509, NID_subject_key_identifier, nil, nil)?.assumingMemoryBound(to: ASN1_OCTET_STRING.self), let subjectId = Data.from(asn1OctetString: rawSubjectId)?.hexEncodedString() {
                keyIdMap[subjectId] = Int(i)
            }

            if let subjectName = X509_NAME_oneline(X509_get_subject_name(x509), nil, 0) {
                let subject = String(cString: subjectName)

                subjectMap[subject] = Int(i)
            }
        }

        if certCount != metadata.certificateCount {
            printError("[\(#fileID):\(#line)] Certificate count from metadata did not match number of certificates imported from bundle. Expected \(metadata.certificateCount) got \(certCount)")
            throw TLSKitError.internalError("Unable to load all certificates from bundle")
        }

        return CertificateBundle(name: name, metadata: metadata, certificateCount: UInt(certCount), bundlePath: bundlePath, keyIdMap: keyIdMap, subjectMap: subjectMap, certs: certs)
    }

    internal func includes(_ x509: X509, subjectKeyId: Data?, subject: OpaquePointer) -> Bool {
        // First, look for a matching certificate using its subject key ID
        if let subjectKeyId = subjectKeyId?.hexEncodedString() {
            printDebug("[\(#fileID):\(#line)] Looking for certificate with key ID \(subjectKeyId) in bundle")
            if let idx = self.keyIdMap[subjectKeyId] {
                printDebug("[\(#fileID):\(#line)] Found certificate at index \(idx)")
                guard let checkCert = D2I.X509(self.certs[idx]) else {
                    return false
                }
                defer {
                    X509_free(checkCert)
                }
                if X509_cmp(x509, checkCert) == 0 {
                    printDebug("[\(#fileID):\(#line)] Matched")
                    return true
                }
                printWarning("[\(#fileID):\(#line)] Certificate with key ID \(subjectKeyId) in bundle did not match")
            }
        }

        // Next, look for a matching certificate using the subject name
        guard let name = X509_NAME_oneline(subject, nil, 0) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_NAME_oneline returned nil")
            return false
        }
        let nameString = String(cString: name)
        if let idx = self.subjectMap[nameString] {
            printDebug("[\(#fileID):\(#line)] Looking for certificate with subject \"\(nameString)\" in bundle")
            guard let checkCert = D2I.X509(self.certs[idx]) else {
                return false
            }
            defer {
                X509_free(checkCert)
            }
            if X509_cmp(x509, checkCert) == 0 {
                printDebug("[\(#fileID):\(#line)] Matched")
                return true
            }
            printWarning("[\(#fileID):\(#line)] Certificate with subject \"\(nameString)\" in bundle did not match")
        }

        // Failing that, iterate through the certificates in the store
        for i in 0..<self.certs.count {
            guard let checkCert = D2I.X509(self.certs[i]) else {
                return false
            }
            defer {
                X509_free(checkCert)
            }
            if X509_cmp(x509, checkCert) == 0 {
                printDebug("[\(#fileID):\(#line)] Matched \(i)")
                return true
            }
        }

        printWarning("[\(#fileID):\(#line)] Certificate not found in bundle")
        return false
    }

    /// If this bundle was embedded in TLSKit or not
    public func embedded() -> Bool {
        return !self.bundlePath.path.contains("rootca")
    }
}
