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
import DNSKit

internal final class Resolver: Sendable {
    static func resolveAddress(fromDomain domain: String, addressFamily: IPAddressVersion?) throws -> IPAddress {
        var hints = addrinfo()
        if let family = addressFamily {
            hints.ai_family = family.family()
        } else {
            hints.ai_family = AF_UNSPEC
        }
        hints.ai_socktype = SOCK_DGRAM
        hints.ai_flags = 0
        hints.ai_protocol = 0
        var resultPtr: UnsafeMutablePointer<addrinfo>?

        printDebug("[\(#fileID):\(#line)] Resolving \(domain)")

        let err = getaddrinfo(domain, nil, &hints, &resultPtr)
        if err != 0 {
            let message = Resolver.getErrorMessage(err)
            printError("[\(#fileID):\(#line)] getaddrinfo \(message)")
            throw TLSKitError.responseError(message)
        }
        guard let result = resultPtr?.pointee else {
            printError("[\(#fileID):\(#line)] getaddrinfo did not populate result")
            throw TLSKitError.internalError("Unable to resolve name")
        }

        let address: IPAddress
        do {
            address = try IPAddress.from(addrinfo: result)
        } catch {
            printError("[\(#fileID):\(#line)] Unable to deseralize IP address from result addrinfo: \(error)")
            throw TLSKitError.invalidData(error.localizedDescription)
        }

        resultPtr?.deallocate()

        printDebug("[\(#fileID):\(#line)] Resolved \(domain) to \(address.string)")

        return address
    }

    static func resolveIp(_ ip: IPAddress) -> String? {
        guard let reply = try? SystemResolver.query(question: Question(name: ip.string, recordType: .PTR)) else {
            return nil
        }
        let record = reply.answers.first {
            return $0.recordType == .PTR
        }
        guard let data = record?.data as? PTRRecordData else {
            return nil
        }
        return data.name
    }

    private static func getErrorMessage(_ code: Int32) -> String {
        switch code {
        case EAI_ADDRFAMILY:
            return "Address family for hostname not supported (EAI::ADDRFAMILY)"
        case EAI_AGAIN:
            return "Temporary failure in name resolution (EAI::AGAIN)"
        case EAI_BADFLAGS:
            return "EAI::BADFLAGS"
        case EAI_FAIL:
            return "Non-recoverable failure in name resolution (EAI::FAIL)"
        case EAI_FAMILY:
            return "EAI::FAMILY"
        case EAI_MEMORY:
            return "EAI::MEMORY"
        case EAI_NODATA:
            return "No address associated with hostname (EAI::NODATA)"
        case EAI_NONAME:
            return "Hostname nor servname provided, or not known (EAI::NONAME)"
        case EAI_SERVICE:
            return "EAI::SERVICE"
        case EAI_SOCKTYPE:
            return "EAI::SOCKTYPE"
        case EAI_SYSTEM:
            return "EAI::SYSTEM"
        default:
            return "EAI::UNKNOWN"
        }
    }
}
