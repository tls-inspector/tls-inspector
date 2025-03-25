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

internal final class I2D {
    static func X509(_ r: OpaquePointer) -> Data? {
        var data: UnsafeMutablePointer<UInt8>?
        let length = i2d_X509(r, &data)
        if data == nil {
            return nil
        }
        if length == 0 {
            return Data()
        }

        return Data(bytes: data!, count: Int(length))
    }

    static func OCSP_REQUEST(_ r: OpaquePointer) -> Data? {
        var data: UnsafeMutablePointer<UInt8>?
        let length = i2d_OCSP_REQUEST(r, &data)
        if data == nil {
            return nil
        }
        if length == 0 {
            return Data()
        }

        return Data(bytes: data!, count: Int(length))
    }

    static func PUBKEY(_ r: OpaquePointer) -> Data? {
        var data: UnsafeMutablePointer<UInt8>?
        let length = i2d_PUBKEY(r, &data)
        if data == nil {
            return nil
        }
        if length == 0 {
            return Data()
        }

        return Data(bytes: data!, count: Int(length))
    }
}
