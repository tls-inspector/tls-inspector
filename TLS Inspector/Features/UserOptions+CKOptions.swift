import UIKit
import CertificateKit

extension UserOptions {
    public static func getterOptions() -> CKGetterOptions {
        let options = CKGetterOptions()

        options.queryServerInfo = UserOptions.getHTTPHeaders
        options.checkOCSP = UserOptions.queryOCSP
        options.checkCRL = UserOptions.checkCRL
        options.useOpenSSL = UserOptions.useOpenSSL
        options.ciphers = UserOptions.preferredCiphers

        return options
    }
}
