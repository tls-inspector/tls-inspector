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

internal func logOpenSSLError(inFile: String, atLine: Int) {
    var opensslFile: UnsafePointer<CChar>?
    var opensslLine: Int32 = -1
    let errorCode = ERR_get_error()
    ERR_peek_last_error_line(&opensslFile, &opensslLine)
    if opensslFile == nil {
        printError("[\(inFile):\(atLine)] (\(errorCode)) Unsuccessful OpenSSL operation but no value returned from ERR_peek_last_error_line")
    } else {
        let fileName = String(cString: opensslFile!)
        printError("[\(inFile):\(atLine)] (\(errorCode)) OpenSSL error in \(fileName):\(opensslLine)")
    }
}
