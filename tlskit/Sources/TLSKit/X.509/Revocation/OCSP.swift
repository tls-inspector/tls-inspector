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

internal enum OCSPStatus {
    case revoked
    case notRevoked
    case notFound
}

internal struct OCSPResult {
    let status: OCSPStatus
    let revocationReason: Int32?
    let revocationDate: Date?
    let informedBy: String?

    init(status: OCSPStatus, revocationReason: Int32? = nil, revocationDate: Date? = nil, informedBy: String? = nil) {
        self.status = status
        self.revocationReason = revocationReason
        self.revocationDate = revocationDate
        self.informedBy = informedBy
    }
}

internal final class OCSPManager {
    static func checkCertificate(_ certificate: Certificate, issuedBy: Certificate) -> Result<OCSPResult?, Error> {
        var urls: [String] = []
        for provider in (certificate.statusProviders ?? []) {
            switch provider {
            case .ocsp(let url):
                urls.append(url)
            default:
                break
            }
        }
        if urls.isEmpty {
            return .success(nil)
        }

        var results: [OCSPResult] = []

        for url in urls {
            let result = queryOcspServerAboutCertificate(certificate, issuedBy: issuedBy, ocsp: url)
            switch result {
            case .success(let ocspResult):
                if ocspResult.status == .revoked {
                    return .success(ocspResult)
                }
                results.append(ocspResult)
            case .failure(_):
                continue
            }
        }

        if results.isEmpty {
            return .failure(MakeError("Unable to check any OCSP specified on the certificate"))
        }

        return .success(results[0])
    }

    fileprivate static func queryOcspServerAboutCertificate(_ certificate: Certificate, issuedBy: Certificate, ocsp: String) -> Result<OCSPResult, Error> {
        guard let certId = OCSP_cert_to_id(nil, certificate.x509, issuedBy.x509) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] OCSP_cert_to_id returned null")
            return .failure(MakeError("Internal error"))
        }
        guard let ocspRequest = OCSP_REQUEST_new() else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] OCSP_REQUEST_new returned null")
            return .failure(MakeError("Internal error"))
        }
        OCSP_request_add0_id(ocspRequest, certId)

        guard let requestData = I2D.OCSP_REQUEST(ocspRequest) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] Error seralizing OCSP request")
            return .failure(MakeError("Internal error"))
        }

        let curl: CurlClient
        do {
            curl = try CurlClient(url: ocsp)
        } catch {
            return .failure(error)
        }
        curl.headers.add("Content-Type", "application/ocsp-request")
        curl.headers.add("Accept", "application/ocsp-response")
        curl.maxBodySize = 20 * (1024 * 1024)
        curl.body = requestData
        let result = curl.post()
        switch result {
        case .success(let http):
            if http.statusCode != 200 {
                return .failure(MakeError("HTTP \(http.statusCode)"))
            }
            if let contentType = http.headers.get1("Content-Type"), contentType.lowercased() != "application/ocsp-response" {
                return .failure(MakeError("OCSP response has incorrect content type '\(contentType)'"))
            }

            guard let ocsp = http.body.withUnsafeBytes({
                var b = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                return d2i_OCSP_RESPONSE(nil, &b, $0.count)
            }) else {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] d2i_X509_CRL returned nil")
                return .failure(MakeError("Error deseralizing CRL response"))
            }
            defer {
                OCSP_RESPONSE_free(ocsp)
            }

            let ocspStatus = OCSP_response_status(ocsp)
            if ocspStatus != OCSP_RESPONSE_STATUS_SUCCESSFUL {
                printError("[\(#fileID):\(#line)] OCSP response code not successful \(ocspStatus)")
                return .failure(MakeError("OCSP server response not successful"))
            }

            guard let resp = OCSP_response_get1_basic(ocsp) else {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] OCSP_response_get1_basic returned nil")
                return .failure(MakeError("OCSP parsing error"))
            }

            var status: Int32 = 0
            var reason: Int32 = 0
            var revtime: UnsafeMutablePointer<ASN1_GENERALIZEDTIME>!
            var thisupd: UnsafeMutablePointer<ASN1_GENERALIZEDTIME>! // not used
            var nextupd: UnsafeMutablePointer<ASN1_GENERALIZEDTIME>! // not used
            if OCSP_resp_find_status(resp, certId, &status, &reason, &revtime, &thisupd, &nextupd) == 0 {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] OCSP_resp_find_status unsuccessful")
                return .failure(MakeError("Internal error"))
            }

            switch status {
            case V_OCSP_CERTSTATUS_GOOD:
                printDebug("[\(#fileID):\(#line)] OCSP status good")
                return .success(OCSPResult(status: .notRevoked))
            case V_OCSP_CERTSTATUS_UNKNOWN:
                printDebug("[\(#fileID):\(#line)] OCSP status unknown")
                return .success(OCSPResult(status: .notFound))
            case V_OCSP_CERTSTATUS_REVOKED:
                printDebug("[\(#fileID):\(#line)] OCSP status revoked")
                var revokedAt: Date?
                if revtime != nil {
                    revokedAt = Date.from(ASN1_GENERALIZEDTIME: revtime)
                } else {
                    printWarning("[\(#fileID):\(#line)] Revoked status but no date provided")
                }

                return .success(OCSPResult(status: .revoked, revocationReason: reason, revocationDate: revokedAt))
            default:
                printError("[\(#fileID):\(#line)] Unknown cert status value \(status)")
                return .failure(MakeError("OCSP parsing error"))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
