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

internal final class BIO: Sendable {
    internal static func getSSL(bio: OpaquePointer) -> OpaquePointer? {
        var ssl: OpaquePointer?
        BIO_ctrl(bio, BIO_C_GET_SSL, 0, &ssl)
        if ssl == nil {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_get_ssl returned nil")
            return nil
        }
        return ssl
    }

    private static func setConnect(bio: OpaquePointer, larg: Int32, val: String) throws {
        let rv = Swift_BIO_ctrl(bio, BIO_C_SET_CONNECT, larg, val)
        printDebug("[\(#fileID):\(#line)] BIO_C_SET_CONNECT \(larg) == \(rv)")
        if rv != 1 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_ctrl \(larg) failed: \(rv)")
            throw TLSKitError.internalError("libssl error")
        }
    }

    internal static func setConnHostname(bio: OpaquePointer, hostname: String) throws {
        try setConnect(bio: bio, larg: 0, val: hostname)
    }

    internal static func setConnPort(bio: OpaquePointer, port: String) throws {
        try setConnect(bio: bio, larg: 1, val: port)
    }

    internal static func setConnAddress(bio: OpaquePointer, address: String) throws {
        try setConnect(bio: bio, larg: 3, val: address)
    }

    private static func setStateMachine(bio: OpaquePointer) throws {
        let rv = BIO_ctrl(bio, BIO_C_DO_STATE_MACHINE, 0, nil)
        if rv < 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_ctrl \(BIO_C_DO_STATE_MACHINE) failed: \(rv)")
            throw TLSKitError.connectionError(TLSKitError.internalError("libssl error"))
        }
    }

    internal static func doConnect(bio: OpaquePointer) throws {
        try setStateMachine(bio: bio)
    }

    internal static func doHandshake(bio: OpaquePointer) throws {
        try setStateMachine(bio: bio)
    }
}
