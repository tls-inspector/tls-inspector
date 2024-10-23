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

internal func SecTry(_ methodReturning: OSStatus) -> Error? {
    if methodReturning == errSecSuccess {
        return nil
    }

    guard let description = SecCopyErrorMessageString(methodReturning, nil) as? String else {
        return MakeError("Unknown error")
    }

    return MakeError(description)
}

internal func SecTrustCopy(_ trustRef: sec_trust_t) -> SecTrust {
    // swiftlint:disable force_cast
    return sec_trust_copy_ref(trustRef) as! SecTrust
    // swiftlint:enable force_cast
}
