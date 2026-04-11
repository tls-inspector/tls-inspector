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

internal final class D2I {
    static func X509(_ data: Data) -> OpaquePointer? {
        guard let bio = try? data.toBIO() else {
            return nil
        }
        defer {
            BIO_free(bio)
        }
        guard let x509 = d2i_X509_bio(bio, nil) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] d2i_X509_bio returned nil")
            return nil
        }
        return x509
    }

    static func X509_CRL(_ data: Data) -> OpaquePointer? {
        guard let bio = try? data.toBIO() else {
            return nil
        }
        defer {
            BIO_free(bio)
        }
        guard let x509 = d2i_X509_CRL_bio(bio, nil) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] d2i_X509_CRL_bio returned nil")
            return nil
        }
        return x509
    }
}
