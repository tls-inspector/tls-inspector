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

/// A list of known certificate authorities that have violated CA/B baseline TLS Requirements.
/// Certificates are represented by a SHA-256 sum (uppercase hex) of the certificate.
///
/// > Warning: These authorities pose significant risk to the safety of internet users worldwide and have violated internationally accepted regulations.
/// >
/// > **Under no circumstances should a connection be trusted if a certificate issue tree is rooted with any of these certificates.**
///
/// ## Current entries:
///
/// ```
/// Version: 3 (0x2)
/// Serial Number: 4096 (0x1000)
/// Signature Algorithm: sha256WithRSAEncryption
/// Issuer: C = RU, O = The Ministry of Digital Development and Communications, CN = Russian Trusted Root CA
/// Validity
///     Not Before: Mar  1 21:04:15 2022 GMT
///     Not After : Feb 27 21:04:15 2032 GMT
/// Subject: C = RU, O = The Ministry of Digital Development and Communications, CN = Russian Trusted Root CA
/// ```
internal let knownBadAuthorities: [String] = [
    "D26D2D0231B7C39F92CC738512BA54103519E4405D68B5BD703E9788CA8ECF31"
]

/// Trust status results
public enum TrustStatus: Int, CaseIterable, Sendable {
    /// The system trusts this certificate.
    case trusted = 1
    /// The system trusts this certificate chain because one or more of the certificates are locally installed and marked as trusted.
    case locallyTrusted = 2
    /// The system does not trust this certificate.
    case untrusted = 3
    /// The system does not trust this certificate because one or more certificates in the chain are expired or not yet valid.
    case invalidDate = 4
    /// The system does not trust this certificate because the server certificate is for a different host.
    case wrongHost = 5
    /// The system does not trust this certificate because the server certificate is signed using SHA-1.
    case sha1Leaf = 6
    /// The system does not trust this certificate because the intermediate certificate is signed using SHA-1.
    case sha1Intermediate = 7
    /// The system does not trust this certificate because it is a self-signed certificate.
    case selfSigned = 8
    /// The system does not trust this certificate because is has been revoked.
    case revokedLeaf = 9
    /// The system does not trust this certificate because the intermediate CA has been revoked.
    case revokedIntermediate = 10
    /// The leaf or intermediate certificate is using an RSA bey with fewer than 2048 bits.
    case weakRSAKey = 11
    /// The leaf certificate has an issue date longer than 825 days.
    case issueDateTooLong = 12
    /// The leaf certificate is missing require key usage permissions.
    case leafMissingRequiredKeyUsage = 13
    /// One or more certificates contain an unknown extension that is marked as critical
    case unknownCriticalExtension = 14
    /// The root or intermediate authority is known to violate internationally accepted rules.
    case badAuthority = 99

    /// Pick an appropriate trust status from the certificate chain and host. This will only try to identify trust failures and should be used if the system has not
    /// trusted the connection.
    /// - Parameters:
    ///   - certificates: The certificates, with the leaf as the first and the root as last
    ///   - host: The address or name of the remote host
    /// - Returns: A trust status
    internal static func fromChain(certificates: [Certificate], peername: String, peeraddress: IPAddress) -> TrustStatus? {
        // Expired/Not Yet Valid
        for certificate in certificates {
            if certificate.validity.isExpired {
                printDebug("[\(#fileID):\(#line)] Certificate '\(certificate.subject)' expired on \(certificate.validity.notAfter)")
                return .invalidDate
            } else if certificate.validity.isNotYetValid {
                printDebug("[\(#fileID):\(#line)] Certificate '\(certificate.subject)' is not valid until \(certificate.validity.notBefore)")
                return .invalidDate
            }
        }

        // Weak RSA
        for certificate in certificates {
            if certificate.publicKey.algorithm == .rsa && certificate.publicKey.size < 2048 {
                printDebug("[\(#fileID):\(#line)] Certificate '\(certificate.subject)' uses weak RSA key sizes \(certificate.publicKey.size)")
                return .weakRSAKey
            }
        }

        // SHA-1 Leaf
        if certificates[0].signatureAlgorithm.lowercased().contains("sha1") {
            printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' uses weak SHA-1 algorithm")
            return .sha1Leaf
        }

        // SHA-1 Intermediate
        if certificates.count > 2 {
            for certificate in certificates[1..<certificates.count-1] where certificate.signatureAlgorithm.lowercased().contains("sha1") {
                printDebug("[\(#fileID):\(#line)] Certificate '\(certificate.subject)' uses weak SHA-1 algorithm")
                return .sha1Leaf
            }
        }

        // Self-signed
        if certificates.count == 1 {
            printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' is self-signed")
            return .selfSigned
        }

        // Revoked leaf
        if certificates[0].statusResults?.first(where: { $0.revoked }) != nil {
            printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' is revoked")
            return .revokedLeaf
        }

        // Revoked intermediate
        if certificates.count > 2 {
            for certificate in certificates[1..<certificates.count-1] where certificate.statusResults?.first(where: { $0.revoked }) != nil {
                printDebug("[\(#fileID):\(#line)] Certificate '\(certificate.subject)' is revoked")
                return .revokedIntermediate
            }
        }

        // Wrong host
        guard let alternateNames = certificates[0].alternateNames else {
            printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' has no subject alternate names")
            return .wrongHost
        }
        var foundMatchingAlternateName = false
        let hostParts = peername.split(separator: ".")
        for san in alternateNames {
            switch san {
            case .dns(let dns):
                let nameParts = dns.split(separator: ".")
                if hostParts.count != nameParts.count {
                    printDebug("[\(#fileID):\(#line)] Host '\(peername)' does not match DNS alternate name '\(dns)'")
                    continue
                }

                // DNS alternate name rules:
                //
                // Underscores prohibited
                //
                // Only the first component of the SAN can be a wildcard
                // Valid: *.example.com
                // Invalid: mail.*.example.com
                //
                // Wildcards only match the same-level of the domain. I.E. *.example.com:
                // Match: mail.example.com
                // Match: chat.example.com
                // Doesn't match: video.mail.example.com
                if dns.contains("_") {
                    printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' contains illegal DNS alternate name '\(dns)'")
                    break
                }
                let hasWildcard = nameParts[0] == "*"
                var validComponents = true
                for i in 0..<nameParts.count {
                    if i == 0 {
                        if hostParts[i] != nameParts[i] && !hasWildcard {
                            printDebug("[\(#fileID):\(#line)] Host '\(peername)' does not match DNS alternate name '\(dns)'")
                            validComponents = false
                            break
                        }
                    } else {
                        if hostParts[i] != nameParts[i] {
                            printDebug("[\(#fileID):\(#line)] Host '\(peername)' does not match DNS alternate name '\(dns)'")
                            validComponents = false
                            break
                        }
                    }
                }
                if validComponents {
                    printDebug("[\(#fileID):\(#line)] Host '\(peername)' matched DNS alternate name '\(dns)'")
                    foundMatchingAlternateName = true
                    break
                }
            case .ipAddress(let ip):
                if peeraddress == ip {
                    printDebug("[\(#fileID):\(#line)] Host '\(peeraddress.string)' matched IP alternate name '\(ip.string)'")
                    foundMatchingAlternateName = true
                    break
                }
                printDebug("[\(#fileID):\(#line)] Host '\(peeraddress.string)' does not match IP alternate name '\(ip.string)'")
            default:
                break
            }
        }
        if !foundMatchingAlternateName {
            printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' did not contain any subject alternate name that matched name '\(peername)' or address '\(peeraddress)'")
            return .wrongHost
        }

        // Server cert is missing serverAuth EKU
        // TODO: -

        // Issue date too long
        if certificates[0].validity.validFor > 825 {
            printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' has a validity period that is too long")
            return .issueDateTooLong
        }

        // The only certificate extension we can safely assume is actually "unknown" is the precertificate poision extension
        for certificate in certificates {
            for ext in certificate.extensions ?? [] where ext.critical {
                if ext.oid == "1.3.6.1.4.1.11129.2.4.3" {
                    printDebug("[\(#fileID):\(#line)] Certificate '\(certificates[0].subject)' has unknown critical extension \(ext.oid)")
                    return .unknownCriticalExtension
                }
            }
        }

        return nil
    }
}
