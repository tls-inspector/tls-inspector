import UIKit
import CertificateKit

// swiftlint:disable identifier_name
var CERTIFICATE_CHAIN: CKCertificateChain?
var HTTP_SERVER_INFO: CKHTTPServerInfo?
var SERVER_ERROR: Error?
var CURRENT_CERTIFICATE: Int = 0
var SPLIT_VIEW_CONTROLLER: UISplitViewController?
var VIEW_CLOSE_NOTIFICATION: Notification.Name = Notification.Name("view_close")
var RELOAD_RECENT_NOTIFICATION: Notification.Name = Notification.Name("reload_recent")
var SHOW_TIPS_NOTIFICATION: Notification.Name = Notification.Name("show_tips")
var CHANGE_CRYPTO_NOTIFICATION: Notification.Name = Notification.Name("change_crypto")
// swiftlint:enable identifier_name

let AppDefaults = UserDefaults(suiteName: "group.com.ecnepsnai.TLS-Inspector")!

func IsExtension() -> Bool {
    return Bundle.main.bundleIdentifier == "com.ecnepsnai.Certificate-Inspector.Inspect-Website"
}

func RunOnMain(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func NewError(description: String) -> Error {
    return NSError(domain: "io.ecn.tlsinspector", code: 500,
                   userInfo: [NSLocalizedDescriptionKey: description]) as Error
}

func LogError(_ message: String) {
    CKLogging.sharedInstance().writeError(message)
}

func LogWarn(_ message: String) {
    CKLogging.sharedInstance().writeWarn(message)
}

func LogInfo(_ message: String) {
    CKLogging.sharedInstance().writeInfo(message)
}

func LogDebug(_ message: String) {
    CKLogging.sharedInstance().writeDebug(message)
}

protocol ReloadableInspectTarget {
    func reloadWithQuery(query: String)
}

var reloadInspectionTarget: ReloadableInspectTarget?
