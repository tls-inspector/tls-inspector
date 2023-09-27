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

        if let server = UserOptions.dohServer {
            parameters.dnsOverHTTPSServer = server.url
            parameters.dohFallbackToSystemDNS = UserOptions.dohFallback
        }

        return parameters
    }
}
