// Crashpad
// Copyright (C) Ian Spence and other Crashpad Contributors
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
import Bsdresolve

private struct ThumbprintRecord {
    let thumbprint: String
    let signature: String
    let keyId: UInt8
}

internal enum DNSError: Error {
    case query
    case parse
    case noThumbprint
    case keyParse
    case signatureParse
    case signatureVerify
}

internal final class DNS {
    private static let publicKey = Data([
        0x04, 0x1d, 0xa8, 0x52, 0x6c, 0xaa, 0xf2, 0x40, 0x05, 0x42, 0x0c, 0x34, 0xb8,
        0x78, 0xe4, 0xaf, 0x9d, 0xb1, 0x49, 0x58, 0xc1, 0xea, 0xe1, 0xbd, 0xcd, 0x8e,
        0xa3, 0xf4, 0x8a, 0x6f, 0x9e, 0x0b, 0x88, 0xf0, 0x11, 0xbe, 0xab, 0x62, 0x28,
        0x46, 0xc2, 0x85, 0x9d, 0xf4, 0x56, 0xaa, 0xd4, 0x8d, 0xbe, 0x4b, 0x90, 0x91,
        0x21, 0x74, 0x9a, 0x92, 0x8f, 0x31, 0xda, 0x1d, 0x7f, 0x4e, 0x33, 0xd0, 0x12
    ])

    static func txtRecordsFor(_ zone: String) throws -> [String] {
        var answer = [UInt8](repeating: 0, count: Int(NS_PACKETSZ))

        let len = zone.withCString { cstr in
            return res_9_query(
                cstr,
                Int32(ns_c_in.rawValue),
                Int32(ns_t_txt.rawValue),
                &answer,
                Int32(answer.count)
            )
        }

        guard len > 0 else {
            throw DNSError.query
        }

        var handle = res_9_ns_msg()
        if res_9_ns_initparse(answer, len, &handle) < 0 {
            throw DNSError.query
        }

        var results: [String] = []
        let count = Int(handle._counts.1)

        for i in 0..<count {
            var rr = res_9_ns_rr()
            if res_9_ns_parserr(&handle, ns_s_an, Int32(i), &rr) == 0 {
                guard let rdata = rr.rdata else {
                    throw DNSError.parse
                }
                let rdlen = rr.rdlength

                var offset = 0
                while offset < rdlen {
                    let txtLen = Int(rdata[offset])
                    if txtLen > 0, offset + 1 + txtLen <= rdlen {
                        let txt = String(decoding: UnsafeBufferPointer(start: rdata+offset+1, count: txtLen), as: UTF8.self)
                        results.append(txt)
                    }
                    offset += 1 + txtLen
                }
            }
        }

        return results
    }

    static func getAndVerifyFingerprint(forHost host: String) throws -> Data {
        let records = try DNS.txtRecordsFor(host)

        guard let thumbprintRecordStr = records.filter({ $0.hasPrefix("tls.thumbprint;")}).first else {
            throw DNSError.noThumbprint
        }

        let thumbprintRecord = try parseThumbprintRecord(thumbprintRecordStr)

        var keyError: Unmanaged<CFError>?
        let keyAttributes = [
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ] as CFDictionary
        guard let key = SecKeyCreateWithData(publicKey as CFData, keyAttributes, &keyError) else {
            throw DNSError.keyParse
        }

        guard let thumbprint = Data(hex: thumbprintRecord.thumbprint) else {
            throw DNSError.signatureParse
        }
        guard let signature = Data(hex: thumbprintRecord.signature) else {
            throw DNSError.signatureParse
        }

        var verifyError: Unmanaged<CFError>?
        let verified = SecKeyVerifySignature(key, .ecdsaSignatureDigestX962SHA256, thumbprint.sha256() as CFData, signature as CFData, &verifyError)

        if !verified {
            throw DNSError.signatureVerify
        }

        return thumbprint
    }

    private static func parseThumbprintRecord(_ record: String) throws -> ThumbprintRecord {
        let keyParts = record.split(separator: ";")
        if keyParts.count != 2 {
            throw DNSError.noThumbprint
        }
        let components = keyParts[1].split(separator: ",")

        var thumbprint: String?
        var signature: String?
        var keyId: UInt8?

        for component in components {
            let kvPair = component.split(separator: "=")
            if kvPair.count != 2 {
                continue
            }
            let key = kvPair[0]
            let value = kvPair[1]

            switch key {
            case "sha256":
                thumbprint = String(value)
            case "sig":
                signature = String(value)
            case "keyId":
                keyId = UInt8.init(value)
            default:
                break
            }
        }

        guard let thumbprint = thumbprint, let signature = signature, let keyId = keyId else {
            throw DNSError.noThumbprint
        }

        return ThumbprintRecord(thumbprint: thumbprint, signature: signature, keyId: keyId)
    }
}
