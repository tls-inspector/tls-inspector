// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import TLSUI
import DNSKit

private enum VersionError: Error {
    case invalidVersion
}

private struct TLSInspectorVersion: Sendable {
    let iosVersion: Int
    let appVersion: SemVer
    let isEndOfLife: Bool

    init(txtData: String) throws {
        let parts = txtData.split(separator: ",")
        if parts.count != 3 {
            throw VersionError.invalidVersion
        }
        guard let minimumIosVersion = Int(parts[0]), let appVersion = try? SemVer(string: String(parts[1])) else {
            throw VersionError.invalidVersion
        }
        self.iosVersion = minimumIosVersion
        self.appVersion = appVersion
        self.isEndOfLife = parts[2] == "1"
    }
}

@MainActor
internal final class UpdateCheck {
    private static let queue = DispatchQueue(label: "com.ecnepsnai.Certificate-Inspector.UpdateCheck")

    private static func getLatestVersionFromDNS(_ completion: @Sendable @escaping ([TLSInspectorVersion]?) -> Void) {
        queue.async {
            do {
                let reply = try SystemResolver.query(question: Question(name: "ios-release.tlsinspector.com", recordType: .TXT), dnssecOk: true)
                if reply.responseCode != .NOERROR {
                    LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] DNS reply error for ios-release.tlsinspector.com: \(reply.responseCode.string())")
                    completion(nil)
                    return
                }
                if reply.answers.isEmpty {
                    LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] No DNS answers for TXT ios-release.tlsinspector.com")
                    completion(nil)
                    return
                }
                let authenticateResult = try SystemResolver.authenticate(message: reply)
                if !authenticateResult.chainTrusted {
                    LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] DNS signing chain untrusted for ios-release.tlsinspector.com")
                    completion(nil)
                    return
                }
                if !authenticateResult.signatureVerified {
                    LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] DNS message signature did not verify for ios-release.tlsinspector.com")
                    completion(nil)
                    return
                }

                // TXT record format is:
                // { Minimum iOS Version},{ App Version },{ Is end of life (bool}
                // colon separated
                for record in reply.answers where record.recordType == .TXT {
                    guard let data = record.data as? TXTRecordData else {
                        continue
                    }

                    // Get all versions
                    var allVersions: [TLSInspectorVersion] = []
                    for txtVersion in data.text.split(separator: ":") {
                        guard let version = try? TLSInspectorVersion(txtData: String(txtVersion)) else {
                            continue
                        }
                        allVersions.append(version)
                    }

                    // Only one record is allowed
                    completion(allVersions)
                    return
                }
            } catch {
                LogWriter.shared.write(.Error, message: "Error checking for app updates: \(error)")
            }
        }
    }

    /// Check for a newer version of TLS Inspector by querying DNS records on tls-inspector.com
    /// - Parameter completion: callback that is called when a result has been determined or an error has occured. The passed Bool will only be true if we successfully queried for versions and found a newer version to be available.
    static func checkForNewerVersion(completion: @escaping @Sendable (Bool) -> Void) {
        LogWriter.shared.write(.Debug, message: "Checking for newer versions defined on TXT ios-release.tlsinspector.com")

        let currentIosVersion = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        // let currentAppVersion = (try? SemVer(string: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0")) ?? SemVer(major: 0, minor: 0, patch: 0)
        let currentAppVersion = SemVer(major: 2, minor: 1, patch: 2)
        UpdateCheck.getLatestVersionFromDNS { versions in
            guard let versions = versions else {
                completion(false)
                return
            }
            var latestVersion: TLSInspectorVersion?
            for version in versions {
                if currentIosVersion <= version.iosVersion {
                    continue
                }
                if latestVersion != nil {
                    if version.appVersion > latestVersion!.appVersion {
                        latestVersion = version
                    }
                } else {
                    latestVersion = version
                }
            }

            guard let latestVersion = latestVersion else {
                completion(false)
                return
            }

            LogWriter.shared.write(.Debug, message: "Latest app release supporting devices running iOS \(currentIosVersion): \(latestVersion.appVersion.string()). Installed app version: \(currentAppVersion.string())")
            completion(currentAppVersion < latestVersion.appVersion)
        }
    }
}

private struct SemVer: Sendable, Comparable {
    let major: Int
    let minor: Int
    let patch: Int

    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    init(string: String) throws {
        let parts = string.split(separator: ".")
        if parts.count == 3 {
            guard let major = Int(parts[0]), let minor = Int(parts[1]), let patch = Int(parts[2]) else {
                throw VersionError.invalidVersion
            }
            self.major = major
            self.minor = minor
            self.patch = patch
        } else if parts.count == 2 {
            guard let major = Int(parts[0]), let minor = Int(parts[1]) else {
                throw VersionError.invalidVersion
            }
            self.major = major
            self.minor = minor
            self.patch = 0
        } else if parts.count == 1 {
            guard let major = Int(parts[0]) else {
                throw VersionError.invalidVersion
            }
            self.major = major
            self.minor = 0
            self.patch = 0
        } else {
            throw VersionError.invalidVersion
        }
    }

    static func < (lhs: borrowing SemVer, rhs: borrowing SemVer) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }

        return lhs.patch < rhs.patch
    }

    func string() -> String {
        return "\(major).\(minor).\(patch)"
    }
}
