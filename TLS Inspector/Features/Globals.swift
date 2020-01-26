import UIKit
import CertificateKit

// swiftlint:disable identifier_name
var CERTIFICATE_CHAIN: CKCertificateChain?
var SERVER_INFO: CKServerInfo?
var CURRENT_CERTIFICATE: Int = 0
var SPLIT_VIEW_CONTROLLER: UISplitViewController?
var VIEW_CLOSE_NOTIFICATION: Notification.Name = Notification.Name("🏳️‍🌈")
var RELOAD_RECENT_NOTIFICATION: Notification.Name = Notification.Name("🇹🇼")
var SHOW_TIPS_NOTIFICATION: Notification.Name = Notification.Name("🇭🇰")
// swiftlint:enable identifier_name

let AppDefaults = UserDefaults(suiteName: "group.com.ecnepsnai.TLS-Inspector")!

func RunOnMain(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func NewError(description: String) -> Error {
    return NSError(domain: "io.ecn.tlsinspector", code: 500,
                   userInfo: [NSLocalizedDescriptionKey: description]) as Error
}
