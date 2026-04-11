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

internal extension String {
    func escapeNewlines() -> String {
        return self.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\r", with: "\\r")
    }

    func kvSplit() -> (String, String) {
        let parts = self.split(separator: ":")
        if parts.count != 2 {
            return ("", "")
        }

        let key = String(parts[0].trimmingCharacters(in: .whitespaces))
        let value = String(parts[1].trimmingCharacters(in: .whitespaces))

        return (key, value)
    }

    static func from(data: Data) -> String? {
        if #available(iOS 18, *) {
            return String(validating: data, as: UTF8.self)
        } else {
            return String(data: data, encoding: .utf8)
        }
    }

    static func from(asn1: UnsafePointer<ASN1_STRING>) -> String? {
        guard let data = ASN1_STRING_get0_data(asn1) else {
            return nil
        }

        return String(cString: data)
    }

    static func from(asn1OctetString: UnsafePointer<ASN1_OCTET_STRING>) -> String? {
        guard let data = asn1OctetString.pointee.data else {
            return nil
        }

        return String(cString: data)
    }

    static func from(asn1UTFString: UnsafePointer<ASN1_UTF8STRING>) -> String? {
        guard let data = asn1UTFString.pointee.data else {
            return nil
        }

        return String(cString: data)
    }

    static func from(obj: OpaquePointer, maxLength: Int, numerical: Bool = false) -> String? {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: maxLength)
        defer {
            buffer.deallocate()
        }
        OBJ_obj2txt(buffer, Int32(maxLength), obj, numerical ? 1 : 0)
        return String(validatingCString: buffer)
    }

    func utf8() -> Data {
        return self.data(using: .utf8)!
    }
}
