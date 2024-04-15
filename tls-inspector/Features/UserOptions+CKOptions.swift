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
        case .OpenSSL:
            parameters.cryptoEngine = .openSSL
        }
        parameters.ciphers = UserOptions.preferredCiphers

        switch UserOptions.ipVersion {
        case .Automatic:
            parameters.ipVersion = .versionUnspecified
        case .IPv4:
            parameters.ipVersion = .version4
        case .IPv6:
            parameters.ipVersion = .version6
        }

        parameters.timeout = UserOptions.inspectTimeout

        return parameters
    }
}
