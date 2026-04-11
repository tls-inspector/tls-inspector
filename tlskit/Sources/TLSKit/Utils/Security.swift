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
import CommonCrypto

internal func SecTry(_ methodReturning: OSStatus) -> TLSKitError? {
    if methodReturning == errSecSuccess {
        return nil
    }

    guard let description = SecCopyErrorMessageString(methodReturning, nil) as? String else {
        printError("[\(#fileID):\(#line)] SecCopyErrorMessageString returned nil")
        return .internalError("Unknown error")
    }

    return .internalError(description)
}

internal func SecTrustCopy(_ trustRef: sec_trust_t) -> SecTrust {
    // swiftlint:disable force_cast
    return sec_trust_copy_ref(trustRef) as! SecTrust
    // swiftlint:enable force_cast
}

internal func hashFile(_ path: URL) throws -> String {
    let data = try Data(contentsOf: path)
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash).hexEncodedString()
}

/// Returns true if an HTTP proxy is configured on this device.
/// - Returns: True if a HTTP proxy is configured, both a host address and port must be specified.
public func isProxyEnabled() -> Bool {
    guard let proxySettingsRef = CFNetworkCopySystemProxySettings() else {
        return false
    }
    defer {
        proxySettingsRef.release()
    }
    let proxySettings = proxySettingsRef.takeUnretainedValue() as NSDictionary
    guard let proxyStr = proxySettings.value(forKey: kCFNetworkProxiesHTTPProxy as String) as? String else {
        return false
    }

    return proxyStr.count > 0
}
