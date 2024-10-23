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

internal final class D2I {
    static func X509(_ data: Data) -> OpaquePointer? {
        var b = data
        let bytesPtr = b.withUnsafeMutableBytes {
            return $0.baseAddress
        }
        var bytesPtrPtr = UnsafePointer<UInt8>(OpaquePointer(bytesPtr))

        return d2i_X509(nil, &bytesPtrPtr, data.count)
    }
}
