import UIKit
import CertificateKit

extension UserOptions {
    public static func inspectParameters(hostAddress: String) -> CKInspectParameters {
        let parameters = CKInspectParameters.fromQuery(hostAddress)

        parameters.queryServerInfo = UserOptions.getHTTPHeaders
        parameters.checkOCSP = UserOptions.queryOCSP
        parameters.checkCRL = UserOptions.checkCRL
        switch UserOptions.cryptoEngine {
        case .NetworkFramework:
            parameters.cryptoEngine = .networkFramework
        case .SecureTransport:
            parameters.cryptoEngine = .secureTransport
        case .OpenSSL:
            parameters.cryptoEngine = .openSSL
        }
        parameters.ciphers = UserOptions.preferredCiphers

        switch UserOptions.ipVersion {
        case .Automatic:
            parameters.ipVersion = .automatic
        case .IPv4:
            parameters.ipVersion = .iPv4
        case .IPv6:
            parameters.ipVersion = .iPv6
        }

        parameters.secureDNSMode = .disabled
        if UserOptions.secureDNS.mode != .HTTPS {
            if let host = UserOptions.secureDNS.host {
                parameters.secureDNSMode = .HTTPS
                parameters.secureDNSServer = host
                parameters.secureDNSFallback = UserOptions.secureDNS.fallback ?? false
            }
        }

        return parameters
    }
}
