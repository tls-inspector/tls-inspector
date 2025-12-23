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

internal enum OCSPStatus {
    case revoked
    case notRevoked
    case notFound
}

internal struct OCSPResult {
    let status: OCSPStatus
    let revocationReason: Int32?
    let revocationDate: Date?
    let informedBy: String

    init(status: OCSPStatus, revocationReason: Int32? = nil, revocationDate: Date? = nil, informedBy: String) {
        self.status = status
        self.revocationReason = revocationReason
        self.revocationDate = revocationDate
        self.informedBy = informedBy
    }
}

internal final class OCSPManager {
    static func checkCertificate(_ certificate: Certificate, issuedBy: Certificate) -> Result<[OCSPResult], TLSKitError> {
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
            return .success([])
        }

        var results: [OCSPResult] = []
        var lastError: TLSKitError?

        for url in urls {
            let result = queryOcspServerAboutCertificate(certificate, issuedBy: issuedBy, ocspUrl: url)
            switch result {
            case .success(let ocspResult):
                if ocspResult.status == .revoked {
                    results.append(ocspResult)
                }
                results.append(ocspResult)
            case .failure(let error):
                lastError = error
                continue
            }
        }

        if results.isEmpty {
            if let error = lastError {
                return .failure(.internalError(error.localizedDescription))
            }
            return .failure(.responseError("No OCSP response received"))
        }

        return .success(results)
    }

    private static func queryOcspServerAboutCertificate(_ certificate: Certificate, issuedBy: Certificate, ocspUrl: String) -> Result<OCSPResult, TLSKitError> {
        guard let certId = OCSP_cert_to_id(nil, certificate.x509, issuedBy.x509) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] OCSP_cert_to_id returned null")
            return .failure(.invalidData("Unable to determine certificate ID"))
        }
        guard let ocspRequest = OCSP_REQUEST_new() else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] OCSP_REQUEST_new returned null")
            return .failure(.internalError("libssl error"))
        }
        OCSP_request_add0_id(ocspRequest, certId)

        guard let requestData = I2D.OCSP_REQUEST(ocspRequest) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] Error seralizing OCSP request")
            return .failure(.internalError("libssl error"))
        }

        let curl: CurlClient
        do {
            curl = try CurlClient(url: ocspUrl)
        } catch {
            return .failure(.internalError(error.localizedDescription))
        }
        curl.headers.add("Content-Type", "application/ocsp-request")
        curl.headers.add("Accept", "application/ocsp-response")
        curl.maxBodySize = 20 * (1024 * 1024)
        curl.body = requestData

        let http: CurlResponse
        do {
            http = try curl.post().get()
        } catch {
            return .failure(error)
        }

        if http.statusCode != 200 {
            return .failure(.httpError(Int(http.statusCode)))
        }
        if let contentType = http.headers.get1("Content-Type"), contentType.lowercased() != "application/ocsp-response" {
            return .failure(.invalidContentType(contentType))
        }

        guard let ocsp = http.body.withUnsafeBytes({
            var b = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            return d2i_OCSP_RESPONSE(nil, &b, $0.count)
        }) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] d2i_X509_CRL returned nil")
            return .failure(.invalidData("Invalid OCSP data"))
        }
        defer {
            OCSP_RESPONSE_free(ocsp)
        }
        return parseOcspResponse(ocspUrl, ocsp, certId)
    }

    private static func parseOcspResponse(_ url: String, _ ocsp: OpaquePointer, _ certId: OpaquePointer) -> Result<OCSPResult, TLSKitError> {
        let ocspStatus = OCSP_response_status(ocsp)
        if ocspStatus != OCSP_RESPONSE_STATUS_SUCCESSFUL {
            printError("[\(#fileID):\(#line)] OCSP response code not successful \(ocspStatus)")
            return .failure(.responseError("OCSP server response not successful"))
        }

        guard let resp = OCSP_response_get1_basic(ocsp) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] OCSP_response_get1_basic returned nil")
            return .failure(.invalidData("Invalid OCSP data"))
        }

        var status: Int32 = 0
        var reason: Int32 = 0
        var revtime: UnsafeMutablePointer<ASN1_GENERALIZEDTIME>!
        var thisupd: UnsafeMutablePointer<ASN1_GENERALIZEDTIME>! // not used
        var nextupd: UnsafeMutablePointer<ASN1_GENERALIZEDTIME>! // not used
        if OCSP_resp_find_status(resp, certId, &status, &reason, &revtime, &thisupd, &nextupd) == 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] OCSP_resp_find_status unsuccessful")
            return .failure(.invalidData("Invalid OCSP data"))
        }

        switch status {
        case V_OCSP_CERTSTATUS_GOOD:
            printDebug("[\(#fileID):\(#line)] OCSP status good")
            return .success(OCSPResult(status: .notRevoked, informedBy: url))
        case V_OCSP_CERTSTATUS_UNKNOWN:
            printDebug("[\(#fileID):\(#line)] OCSP status unknown")
            return .success(OCSPResult(status: .notFound, informedBy: url))
        case V_OCSP_CERTSTATUS_REVOKED:
            printDebug("[\(#fileID):\(#line)] OCSP status revoked")
            var revokedAt: Date?
            if revtime != nil {
                revokedAt = Date.from(ASN1_GENERALIZEDTIME: revtime)
            } else {
                printWarning("[\(#fileID):\(#line)] Revoked status but no date provided")
            }

            return .success(OCSPResult(status: .revoked, revocationReason: reason, revocationDate: revokedAt, informedBy: url))
        default:
            printError("[\(#fileID):\(#line)] Unknown cert status value \(status)")
            return .failure(.invalidData("Invalid OCSP data"))
        }
    }
}
