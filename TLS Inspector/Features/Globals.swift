import UIKit
import CertificateKit

// swiftlint:disable identifier_name
var CERTIFICATE_CHAIN: CKCertificateChain?
var SERVER_INFO: CKServerInfo?
var CURRENT_CERTIFICATE: Int = 0
var SPLIT_VIEW_CONTROLLER: UISplitViewController?
// swiftlint:enable identifier_name

func RunOnMain(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func NewError(description: String) -> Error {
    return NSError(domain: "io.ecn.tlsinspector", code: 500,
                   userInfo: [NSLocalizedDescriptionKey: description]) as Error
}

func OpenURLInSafari(_ urlString: String) {
    guard let url = URL(string: urlString) else {
        return
    }

    UIApplication.shared.openURL(url)
}
