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

internal enum CRLStatus {
    case revoked
    case notFound
}

internal struct CRLResult {
    let status: CRLStatus
    let revocationReason: Int32?
    let revocationDate: Date?
    let informedBy: String

    init(status: CRLStatus, revocationReason: Int32? = nil, revocationDate: Date? = nil, informedBy: String) {
        self.status = status
        self.revocationReason = revocationReason
        self.revocationDate = revocationDate
        self.informedBy = informedBy
    }
}

internal final class CRLManager {
    static func checkCertificate(_ certificate: Certificate, issuedBy: Certificate) -> Result<[CRLResult], TLSKitError> {
        var urls: [String] = []
        for provider in (certificate.statusProviders ?? []) {
            switch provider {
            case .crl(let url):
                urls.append(url)
            default:
                break
            }
        }
        if urls.isEmpty {
            return .success([])
        }

        var results: [CRLResult] = []
        var lastError: TLSKitError?

        for url in urls {
            let result = checkCertificateAgainstCrl(certificate, issuedBy: issuedBy, crlUrl: url)
            switch result {
            case .success(let crlResult):
                if crlResult.status == .revoked {
                    results.append(crlResult)
                }
                results.append(crlResult)
            case .failure(let error):
                lastError = error
                continue
            }
        }

        if results.isEmpty {
            if let error = lastError {
                return .failure(error)
            }

            return .failure(.responseError("No results"))
        }

        return .success(results)
    }

    internal static func check(certificate: Certificate, issuedBy: Certificate, crlUrl: String, data: Data) -> Result<CRLResult, TLSKitError> {
        guard let crl = D2I.X509_CRL(data) else {
            return .failure(.invalidData("Invalid CRL data"))
        }

        guard let issuerKey = X509_get_pubkey(issuedBy.x509) else {
            printError("[\(#fileID):\(#line)] X509_get_pubkey returned nil")
            return .failure(.invalidData("Invalid CRL data"))
        }

        if X509_CRL_verify(crl, issuerKey) != 1 {
            printError("[\(#fileID):\(#line)] CRL verification failure")
            logOpenSSLError(inFile: #fileID, atLine: #line)
            return .failure(.invalidData("CRL verification failed"))
        }

        var revoked: OpaquePointer?
        let rv = X509_CRL_get0_by_cert(crl, &revoked, certificate.x509)
        if rv == 0 {
            // Certificate was not present on CRL
            printDebug("[\(#fileID):\(#line)] Certificate not present on CRL")
            return .success(CRLResult(status: .notFound, informedBy: crlUrl))
        }

        guard let revoked = revoked else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_CRL_get0_by_cert did not populate X509_REVOKED object")
            return .failure(.invalidData("Invalid CRL data"))
        }

        printDebug("[\(#fileID):\(#line)] Certificate present on CRL")

        guard let reasonEnum = X509_REVOKED_get_ext_d2i(revoked, NID_crl_reason, nil, nil)?.assumingMemoryBound(to: ASN1_ENUMERATED.self) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] X509_REVOKED_get_ext_d2i returned nil")
            return .failure(.invalidData("Invalid CRL data"))
        }

        let reason = ASN1_ENUMERATED_get(reasonEnum)

        var revokedAt: Date?
        if let v = X509_REVOKED_get0_revocationDate(revoked) {
            revokedAt = Date.from(ASN1_TIME: v)
        }

        return .success(CRLResult(status: .revoked, revocationReason: Int32(reason), revocationDate: revokedAt, informedBy: crlUrl))

    }

    private static func checkCertificateAgainstCrl(_ certificate: Certificate, issuedBy: Certificate, crlUrl: String) -> Result<CRLResult, TLSKitError> {
        let curl: CurlClient
        do {
            curl = try CurlClient(url: crlUrl)
        } catch {
            return .failure(.internalError(error.localizedDescription))
        }
        curl.headers.add("Accept", "application/pkix-crl")
        curl.maxBodySize = 20 * (1024 * 1024)

        let http: CurlResponse
        do {
            // The two .get()'s are intentional:
            http = try curl.get().get()
            //             .get() <-- HTTP GET request
            //                   .get() <-- get successful result or throw
            printDebug("[\(#fileID):\(#line)] Curl get returned")
        } catch {
            printError("[\(#fileID):\(#line)] Curl get failed: \(error)")
            return .failure(error)
        }

        if http.statusCode != 200 {
            return .failure(.httpError(Int(http.statusCode)))
        }
        if let contentType = http.headers.get1("Content-Type"), contentType.lowercased() != "application/pkix-crl" {
            printError("[\(#fileID):\(#line)] Unexpected content-type: \(contentType)")
            return .failure(.invalidContentType(contentType))
        }
        if http.body.isEmpty {
            printError("[\(#fileID):\(#line)] Empty response body")
            return .failure(.responseError("Empty response body"))
        }

        printDebug("[\(#fileID):\(#line)] Going to attempt to parse \(http.body.count) bytes as CRL")
        return check(certificate: certificate, issuedBy: issuedBy, crlUrl: crlUrl, data: http.body)
    }
}
