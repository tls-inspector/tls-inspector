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

/// Describes a signed certificate timestamp
public struct SignedCertificateTimestamp: Sendable {
    /// The log identifier
    public let logId: Data
    /// The name of the certificate transparency log
    public let logName: String?
    /// The timestamp date
    public let timestamp: Date
    /// The algorithm of the signature
    public let signatureAlgorithm: SignatureAlgorithm
    /// The signature of the timestamp
    public let signature: Data

    internal init(logId: Data, timestamp: Date, signatureAlgorithm: SignatureAlgorithm, signature: Data) {
        self.logId = logId
        self.logName = SignedCertificateTimestamp.findLogName(logId)
        self.timestamp = timestamp
        self.signatureAlgorithm = signatureAlgorithm
        self.signature = signature
    }

    internal static func findLogName(_ logId: Data) -> String? {
        guard let logListPath = Bundle.module.url(forResource: "ct_log_list.min", withExtension: "json") else {
            printError("[\(#fileID):\(#line)] Unable to find ct_log_list.min.json")
            return nil
        }
        let logList: CTLogList
        do {
            let logListData = try Data(contentsOf: logListPath)
            logList = try JSONDecoder().decode(CTLogList.self, from: logListData)
        } catch {
            printError("[\(#fileID):\(#line)] Unable to read ct_log_list.min.json: \(error)")
            return nil
        }
        let logIdBase64 = logId.base64EncodedString()

        for op in logList.operators {
            for ctlog in op.logs where ctlog.log_id == logIdBase64 {
                return ctlog.description
            }
        }

        printWarning("[\(#fileID):\(#line)] Unable to find ct log for id \(logIdBase64)")
        return nil
    }

    internal static func fromSct(_ sct: OpaquePointer!) throws -> SignedCertificateTimestamp {
        var logIdRaw: UnsafeMutablePointer<UInt8>?
        let logIdLength = SCT_get0_log_id(sct, &logIdRaw)
        if logIdLength == 0 || logIdRaw == nil {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SCT_get0_log_id returned 0")
            throw TLSKitError.invalidData("Unable to parse SCT")
        }

        let logId = Data(bytes: logIdRaw!, count: logIdLength)

        let ts = SCT_get_timestamp(sct) // milliseconds
        let timestamp = Date(timeIntervalSince1970: Double(ts)/1000)

        var signatureRaw: UnsafeMutablePointer<UInt8>?
        let signatureLength = SCT_get0_signature(sct, &signatureRaw)
        if signatureLength == 0 || signatureRaw == nil {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SCT_get0_signature returned 0")
            throw TLSKitError.invalidData("Unable to parse SCT")
        }
        let signature = Data(bytes: signatureRaw!, count: signatureLength)

        let sigNid = SCT_get_signature_nid(sct)
        let algorithm = SignatureAlgorithm.from(nid: SCT_get_signature_nid(sct))
        if algorithm == .Unknown {
            printError("[\(#fileID):\(#line)] Unknown or unsupported signature algorithm in SCT: \(sigNid)")
            throw TLSKitError.unrecognizedAlgorithm
        }

        return SignedCertificateTimestamp(logId: logId, timestamp: timestamp, signatureAlgorithm: algorithm, signature: signature)
    }

    internal static func fromCertificate(_ x509: X509) -> [SignedCertificateTimestamp] {
        var scts: [SignedCertificateTimestamp] = []
        guard let sctList = X509_get_ext_d2i(x509, NID_ct_precert_scts, nil, nil) else {
            return []
        }
        let numberOfScts = OPENSSL_sk_num(OpaquePointer(sctList))
        for i in 0..<numberOfScts {
            guard let sctRaw = OPENSSL_sk_value(OpaquePointer(sctList), i) else {
                continue
            }
            if let sct = try? SignedCertificateTimestamp.fromSct(OpaquePointer(sctRaw)) {
                scts.append(sct)
            }
        }

        return scts
    }
}

internal struct CTLogListLog: Codable {
    let description: String
    let log_id: String
}

internal struct CTLogListOperator: Codable {
    let name: String
    let logs: [CTLogListLog]
}

internal struct CTLogList: Codable {
    let operators: [CTLogListOperator]
}
