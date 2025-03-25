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

/// Describes a subject alternative name (SAN)
public enum AlternateName: Sendable, Hashable {
    case dns(String)
    case ipAddress(IPAddress)
    case uri(String)
    case email(String)

    internal static func fromCertificate(_ cert: X509) -> [AlternateName]? {
        guard let rawExt = X509_get_ext_d2i(cert, NID_subject_alt_name, nil, nil) else {
            return nil
        }
        guard let names = OpaquePointer(to: rawExt) else {
            return nil
        }

        let nameCount = OPENSSL_sk_num(names)
        if nameCount <= 0 {
            return nil
        }
        if nameCount > 10_000 {
            printError("[\(#fileID):\(#line)] Certificate has too many alternate names: \(nameCount)")
            return nil
        }

        var sans: [AlternateName] = []

        for i in 0..<nameCount {
            guard let value = OPENSSL_sk_value(names, i)?.assumingMemoryBound(to: GENERAL_NAME.self) else {
                printError("[\(#fileID):\(#line)] OPENSSL_sk_value returned null for index \(i)")
                continue
            }
            switch value.pointee.type {
            case GEN_EMAIL:
                if let email = String.from(asn1: value.pointee.d.ia5) {
                    sans.append(.email(email))
                }
            case GEN_DNS:
                if let dns = String.from(asn1: value.pointee.d.dNSName) {
                    sans.append(.dns(dns))
                }
            case GEN_URI:
                if let uri = String.from(asn1: value.pointee.d.uniformResourceIdentifier) {
                    sans.append(.uri(uri))
                }
            case GEN_IPADD:
                let addrLen = value.pointee.d.ip.pointee.length
                guard let data = value.pointee.d.ip.pointee.data else {
                    break
                }
                if let ipaddr = try? IPAddress(Data(bytes: data, count: Int(addrLen))) {
                    sans.append(.ipAddress(ipaddr))
                }
            default:
                break
            }
        }

        if sans.count == 0 {
            return nil
        }

        return sans
    }
}
