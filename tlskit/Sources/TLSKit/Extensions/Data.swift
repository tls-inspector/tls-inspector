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

internal extension Data {
    static func from(asn1: UnsafePointer<ASN1_STRING>) -> Data? {
        guard let data = ASN1_STRING_get0_data(asn1) else {
            return nil
        }

        let length = ASN1_STRING_length(asn1)

        return Data(bytes: data, count: Int(length))
    }

    static func from(asn1OctetString: UnsafePointer<ASN1_OCTET_STRING>) -> Data? {
        return Data(bytes: asn1OctetString.pointee.data, count: Int(asn1OctetString.pointee.length))
    }

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
