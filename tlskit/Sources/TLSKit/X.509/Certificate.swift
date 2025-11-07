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

/// Possible digest types for certificate fingerprints
public enum CertificateDigestType: Sendable {
    case md5
    case sha1
    case sha256
    case sha512
}

/// Describes a X.509 certificate
public struct Certificate: Sendable, Equatable, Hashable {
    /// The subject name
    public let subject: Name
    /// The issuer name
    public let issuer: Name
    /// If the certificate was self-signed, meaning the subject and issuer are the same
    public let isSelfSigned: Bool
    /// The validity period
    public let validity: ValidityPeriod
    /// The serial number
    public let serial: Data
    /// The signature algorithm of the public key
    public let signatureAlgorithm: String
    /// Subject alternative names
    public let alternateNames: [AlternateName]?
    /// The public key associated with this certificate
    public let publicKey: PublicKey
    /// The key identifier of this certificate
    public let subjectKeyId: Data?
    /// The key identifier of the issuer certificate
    public let authorityKeyId: Data?
    /// Providers for certificate status (both CRL and OCSP)
    public let statusProviders: [StatusProvider]?
    /// Signed certificate timestamps
    public let signedTimestamps: [SignedCertificateTimestamp]?
    /// The revocation status of this certificate. Only populated if the certificate had a status provider and a status check was performed.
    public internal(set) var status: CertificateStatus?
    /// If this certificate has the "Is CA" extension set
    public let isCA: Bool
    /// Basic and extended key usage values for this certificate
    public let keyUsage: KeyUsage?
    /// All extensions of the certificate
    public let extensions: [CertificateExtension]?
    /// The version of this certificate.
    public let version: Int
    /// The source of this certificate, if known
    public let source: CertificateSource?
    /// If the certificate or the key used is present in these bundles. Only populated for CA certificates.
    public let foundInBundles: [BundleProvider: Bool]?

    private let thumbprint: Data

    public static func == (lhs: Certificate, rhs: Certificate) -> Bool {
        return lhs.thumbprint == rhs.thumbprint
    }

    public func hash(into hasher: inout Hasher) {
        self.thumbprint.hash(into: &hasher)
    }

    /// Hash the data of this certificate into a digest, known as a fingerprint or thumbprint, using the given algorithm
    /// - Parameter withType: The digest algorithm to use
    /// - Returns: A cryptographic representation of this certificate
    public func fingerprint(_ withType: CertificateDigestType) throws -> Data {
        let evpMethod: OpaquePointer
        switch withType {
        case .md5:
            evpMethod = EVP_md5()
        case .sha1:
            evpMethod = EVP_sha1()
        case .sha256:
            evpMethod = EVP_sha256()
        case .sha512:
            evpMethod = EVP_sha512()
        }

        var fingerprint = [UInt8](repeating: 0, count: Int(EVP_MAX_MD_SIZE))
        var fingerprintLength = UInt32(fingerprint.count)
        guard X509_digest(self.x509, evpMethod, &fingerprint, &fingerprintLength) > 0 else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_digest returned nil")
            throw TLSKitError.invalidData("unable to digest certificate")
        }

        return Data(bytes: fingerprint, count: Int(fingerprintLength))
    }

    private static func isCertificateTrustedBy(provider: BundleProvider, x509: X509, subjectKeyId: Data?, subject: OpaquePointer) -> Bool {
        do {
            try AnchorBundleManager.shared.loadBundles()
        } catch {
            return false
        }

        switch provider {
        case .apple:
            return AnchorBundleManager.shared.appleBundle?.includes(x509, subjectKeyId: subjectKeyId, subject: subject) ?? false
        case .google:
            return AnchorBundleManager.shared.googleBundle?.includes(x509, subjectKeyId: subjectKeyId, subject: subject) ?? false
        case .microsoft:
            return AnchorBundleManager.shared.microsoftBundle?.includes(x509, subjectKeyId: subjectKeyId, subject: subject) ?? false
        case .mozilla:
            return AnchorBundleManager.shared.mozillaBundle?.includes(x509, subjectKeyId: subjectKeyId, subject: subject) ?? false
        case .tlsInspector:
            return AnchorBundleManager.shared.tlsinspectorBundle?.includes(x509, subjectKeyId: subjectKeyId, subject: subject) ?? false
        }
    }

    nonisolated(unsafe) internal let x509: X509

    internal init(secCertificate: SecCertificate, certificateSource: CertificateSource? = nil) throws {
        let data = SecCertificateCopyData(secCertificate) as Data
        if log?.getLevel() == .Debug {
            printDebug("[\(#fileID):\(#line)] -----BEGIN CERTIFICATE-----\n\(data.base64EncodedString())\n-----END CERTIFICATE-----")
        }
        guard let cert = D2I.X509(data) else {
            throw TLSKitError.invalidData("Invalid X509 certificate data")
        }

        try self.init(x509: cert, certificateSource: certificateSource)
    }

    internal init(x509: X509, certificateSource: CertificateSource? = nil) throws {
        self.source = certificateSource
        self.x509 = x509

        guard let subject = X509_get_subject_name(x509) else {
            printError("[\(#fileID):\(#line)] X509_get_subject_name returned nil")
            throw TLSKitError.invalidCertificate("Missing subject name")
        }
        let subjectName = Name(subject)
        self.subject = subjectName

        guard let issuer = X509_get_issuer_name(x509) else {
            printError("[\(#fileID):\(#line)] X509_get_issuer_name returned nil")
            throw TLSKitError.invalidCertificate("Missing issuer name")
        }
        let issuerName = Name(issuer)
        self.issuer = issuerName

        let isSelfSigned = subjectName == issuerName
        self.isSelfSigned = isSelfSigned

        guard let notBeforeStr = X509_get0_notBefore(x509) else {
            printError("[\(#fileID):\(#line)] X509_get0_notBefore returned nil")
            throw TLSKitError.invalidCertificate("Missing not before date")
        }

        guard let notBefore = Date.from(ASN1_TIME: notBeforeStr) else {
            printError("[\(#fileID):\(#line)] Invalid not before string")
            throw TLSKitError.invalidCertificate("Invalid not before date")
        }

        guard let notAfterStr = X509_get0_notAfter(x509) else {
            printError("[\(#fileID):\(#line)] X509_get0_notAfter returned nil")
            throw TLSKitError.invalidCertificate("Missing not after date")
        }

        guard let notAfter = Date.from(ASN1_TIME: notAfterStr) else {
            printError("[\(#fileID):\(#line)] Invalid not after string")
            throw TLSKitError.invalidCertificate("Invalid not after date")
        }
        self.validity = ValidityPeriod(notBefore: notBefore, notAfter: notAfter)

        guard let serialBytes = X509_get0_serialNumber(x509) else {
            throw TLSKitError.invalidCertificate("Missing serial number")
        }

        guard let serial = Data.from(asn1: serialBytes) else {
            throw TLSKitError.invalidCertificate("Invalid serial number")
        }

        self.serial = serial

        guard let sigType = X509_get0_tbs_sigalg(x509) else {
            throw TLSKitError.invalidCertificate("Unknown signature type")
        }

        guard let signatureAlgorithm = String.from(obj: sigType.pointee.algorithm, maxLength: 128) else {
            throw TLSKitError.invalidCertificate("Unknown signature type")
        }
        self.signatureAlgorithm = signatureAlgorithm

        self.alternateNames = AlternateName.fromCertificate(x509)

        do {
            self.publicKey = try PublicKey.fromCertificate(x509)
        } catch {
            throw TLSKitError.invalidCertificate("Invalid or unsupported public key: \(error.localizedDescription)")
        }

        if let subjectId = X509_get_ext_d2i(x509, NID_subject_key_identifier, nil, nil)?.assumingMemoryBound(to: ASN1_OCTET_STRING.self) {
            self.subjectKeyId = Data.from(asn1OctetString: subjectId)
        } else {
            self.subjectKeyId = nil
        }
        if let authorityId = X509_get_ext_d2i(x509, NID_authority_key_identifier, nil, nil)?.assumingMemoryBound(to: AUTHORITY_KEYID_st.self), let keyId = authorityId.pointee.keyid {
            self.authorityKeyId = Data.from(asn1OctetString: keyId)
        } else {
            self.authorityKeyId = nil
        }

        self.statusProviders = StatusProviderHelper.urlsFromCertificate(x509)

        self.signedTimestamps = SignedCertificateTimestamp.fromCertificate(x509)

        let isCA = Certificate.isCA(x509)
        self.isCA = isCA

        self.keyUsage = KeyUsage.fromCertificate(x509)

        self.extensions = CertificateExtension.fromCertificate(x509)

        self.version = X509_get_version(x509)

        if isCA && isSelfSigned {
            var foundInBundles: [BundleProvider: Bool] = [:]
            for provider in BundleProvider.allCases {
                foundInBundles[provider] = Certificate.isCertificateTrustedBy(provider: provider, x509: x509, subjectKeyId: subjectKeyId, subject: subject)
            }
            self.foundInBundles = foundInBundles
        } else {
            self.foundInBundles = nil
        }

        var thumbprint = [UInt8](repeating: 0, count: Int(EVP_MAX_MD_SIZE))
        var thumbprintLength = UInt32(thumbprint.count)
        guard X509_digest(self.x509, EVP_sha256(), &thumbprint, &thumbprintLength) > 0 else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_digest returned nil")
            throw TLSKitError.invalidData("unable to digest certificate")
        }

        self.thumbprint = Data(bytes: thumbprint, count: Int(thumbprintLength))
    }

    private static func isCA(_ x509: X509) -> Bool {
        guard let constraints = X509_get_ext_d2i(x509, NID_basic_constraints, nil, nil)?.assumingMemoryBound(to: BASIC_CONSTRAINTS_st.self) else {
            return false
        }

        return constraints.pointee.ca > 0
    }

    public func pemString() throws -> String {
        guard let base64 = I2D.X509(x509) else {
            printError("[\(#fileID):\(#line)] I2D_X509 returned nil")
            throw TLSKitError.invalidData("Invalid certificate data")
        }
        return "-----BEGIN CERTIFICATE-----\n\(base64)\n-----END CERTIFICATE-----\n"
    }
}
