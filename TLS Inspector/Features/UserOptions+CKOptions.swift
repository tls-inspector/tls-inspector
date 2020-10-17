import UIKit
import CertificateKit

extension UserOptions {
    public static func getterOptions() -> CKGetterOptions {
        let options = CKGetterOptions()

        options.queryServerInfo = UserOptions.getHTTPHeaders
        options.checkOCSP = UserOptions.queryOCSP
        options.checkCRL = UserOptions.checkCRL
        switch UserOptions.cryptoEngine {
        case .NetworkFramework:
            options.cryptoEngine = CRYPTO_ENGINE_NETWORK_FRAMEWORK.rawValue
        case .SecureTransport:
            options.cryptoEngine = CRYPTO_ENGINE_SECURE_TRANSPORT.rawValue
        case .OpenSSL:
            options.cryptoEngine = CRYPTO_ENGINE_OPENSSL.rawValue
        }
        options.ciphers = UserOptions.preferredCiphers

        return options
    }
}
