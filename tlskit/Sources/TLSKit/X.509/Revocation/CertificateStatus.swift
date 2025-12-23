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

/// Describes providers for certificate status
public enum StatusProvider: Equatable, Hashable, Sendable {
    /// A URL to a certificate revocation list (CRL)
    case crl(String)
    /// A URL to an online certificate status protocol (OCSP) provider
    case ocsp(String)
}

/// Possible reasons a certificate can be revoked.
///
/// Note that TLSKit does not support all possible revocation reasons possible CRL or OCSP responses, such as temporary or "hold" reasons.
public enum RevocationReason: String, Equatable, Hashable, Sendable {
    case keyCompromise
    case caCompromise
    case affiliationChanged
    case superseded
    case cessationOfOperation
    case privilegeWithdrawn
    case aaCompromise
    case unknown

    internal static func fromCrlReason(_ reason: Int32) -> RevocationReason {
        switch reason {
        case 1:
            return .keyCompromise
        case 2:
            return .caCompromise
        case 3:
            return .affiliationChanged
        case 4:
            return .superseded
        case 5:
            return .cessationOfOperation
        case 9:
            return .privilegeWithdrawn
        case 10:
            return .aaCompromise
        default:
            return .unknown
        }
    }

    internal static func fromOcspReason(_ reason: Int32) -> RevocationReason {
        switch reason {
        case OCSP_REVOKED_STATUS_KEYCOMPROMISE:
            return .keyCompromise
        case OCSP_REVOKED_STATUS_CACOMPROMISE:
            return .caCompromise
        case OCSP_REVOKED_STATUS_AFFILIATIONCHANGED:
            return .affiliationChanged
        case OCSP_REVOKED_STATUS_CESSATIONOFOPERATION:
            return .cessationOfOperation
        default:
            return .unknown
        }
    }
}

/// Describes the status of this certificate, if it is revoked or not.
public struct CertificateStatus: Sendable {
    /// Is this certificate revoked or not
    public let revoked: Bool
    /// The reason this certificate was revoked. Always nil if not revoked.
    public let revocationReason: RevocationReason?
    /// The date this certificate was revoked. Always nil if not revoked.
    public let revocationDate: Date?
    /// The status provider that informed us that this certificate is revoked.
    public let informedBy: StatusProvider?

    internal init(revoked: Bool, revocationReason: RevocationReason? = nil, revocationDate: Date? = nil, informedBy: StatusProvider? = nil) {
        self.revoked = revoked
        self.revocationReason = revocationReason
        self.revocationDate = revocationDate
        self.informedBy = informedBy
    }
}

internal final class StatusProviderHelper {
    static func checkCertificates(_ certificates: inout [Certificate], checkCRL: Bool, checkOCSP: Bool) {
        for i in 0..<certificates.count-1 {
            var crlResults: [CRLResult] = []
            var ocspResults: [OCSPResult] = []
            if checkCRL {
                switch CRLManager.checkCertificate(certificates[i], issuedBy: certificates[i+1]) {
                case .success(let results):
                    crlResults = results
                case .failure(let error):
                    printError("[\(#fileID):\(#line)] Failed to get certificate status from CRL: \(error)")
                }
            }
            if checkOCSP {
                switch OCSPManager.checkCertificate(certificates[i], issuedBy: certificates[i+1]) {
                case .success(let results):
                    ocspResults = results
                case .failure(let error):
                    printError("[\(#fileID):\(#line)] Failed to get certificate status from OCSP: \(error)")
                }
            }

            for crl in crlResults {
                var certificate = certificates[i]
                var revoked = false
                var revocationReason: RevocationReason?
                var revocationDate: Date?

                if crl.status == .revoked {
                    revoked = true
                    revocationReason = RevocationReason.fromCrlReason(crl.revocationReason ?? -1)
                    revocationDate = crl.revocationDate
                }

                var results = certificate.statusResults ?? []
                results.append(CertificateStatus(revoked: revoked, revocationReason: revocationReason, revocationDate: revocationDate, informedBy: .crl(crl.informedBy)))
                certificate.statusResults = results

                certificates[i] = certificate
            }

            for ocsp in ocspResults {
                var certificate = certificates[i]
                var revoked = false
                var revocationReason: RevocationReason?
                var revocationDate: Date?

                if ocsp.status == .revoked {
                    revoked = true
                    revocationReason = RevocationReason.fromCrlReason(ocsp.revocationReason ?? -1)
                    revocationDate = ocsp.revocationDate
                }

                var results = certificate.statusResults ?? []
                results.append(CertificateStatus(revoked: revoked, revocationReason: revocationReason, revocationDate: revocationDate, informedBy: .ocsp(ocsp.informedBy)))
                certificate.statusResults = results

                certificates[i] = certificate
            }
        }
    }

    static func urlsFromCertificate(_ x509: X509) -> [StatusProvider]? {
        let crlPoints = StatusProviderHelper.crlPoints(x509)
        let ocspProviders = StatusProviderHelper.ocspProviders(x509)

        if crlPoints == nil && ocspProviders == nil {
            return nil
        }

        return (crlPoints ?? []) + (ocspProviders ?? [])
    }

    private static func crlPoints(_ x509: OpaquePointer) -> [StatusProvider]? {
        guard let ext = X509_get_ext_d2i(x509, NID_crl_distribution_points, nil, nil) else {
            return nil
        }
        let points = OpaquePointer(ext)

        let count = OPENSSL_sk_num(points)
        if count == 0 {
            return nil
        }

        var urls: [StatusProvider] = []

        for i in 0..<count {
            guard let point = OPENSSL_sk_value(points, i)?.assumingMemoryBound(to: DIST_POINT_st.self) else {
                printError("[\(#fileID):\(#line)] Unable to cast NID_crl_distribution_points value to DIST_POINT_st")
                continue
            }

            let fullName = point.pointee.distpoint.pointee.name.fullname
            guard let name = OPENSSL_sk_value(fullName, 0)?.assumingMemoryBound(to: GENERAL_NAME.self) else {
                printError("[\(#fileID):\(#line)] Unable to cast DIST_POINT_st value to GENERAL_NAME")
                continue
            }
            if name.pointee.type != GEN_URI {
                printDebug("[\(#fileID):\(#line)] Ignoring non-URI type CRL provider")
                continue
            }
            guard let url = String.from(asn1: name.pointee.d.uniformResourceIdentifier) else {
                printError("[\(#fileID):\(#line)] Unable to deseralize URL from ASN1 object")
                continue
            }

            urls.append(.crl(url))
        }

        if urls.count == 0 {
            return nil
        }

        return urls
    }

    private static func ocspProviders(_ x509: OpaquePointer) -> [StatusProvider]? {
        guard let ext = X509_get_ext_d2i(x509, NID_info_access, nil, nil) else {
            return nil
        }
        let points = OpaquePointer(ext)

        let count = OPENSSL_sk_num(points)
        if count == 0 {
            return nil
        }

        var urls: [StatusProvider] = []

        for i in 0..<count {
            guard let description = OPENSSL_sk_value(points, i)?.assumingMemoryBound(to: ACCESS_DESCRIPTION_st.self) else {
                printError("[\(#fileID):\(#line)] Unable to cast NID_info_access value to ACCESS_DESCRIPTION_st")
                continue
            }
            if OBJ_obj2nid(description.pointee.method) != NID_ad_OCSP {
                continue
            }
            if description.pointee.location.pointee.type != GEN_URI {
                printDebug("[\(#fileID):\(#line)] Ignoring non-URI type OCSP provider")
                continue
            }
            guard let ia5 = i2s_ASN1_IA5STRING(nil, description.pointee.location.pointee.d.ia5) else {
                printError("[\(#fileID):\(#line)] Unable to deseralize URL from ASN1.IA5 object")
                continue
            }
            let url = String(cString: ia5)
            urls.append(.ocsp(url))
        }

        if urls.count == 0 {
            return nil
        }

        return urls
    }
}
