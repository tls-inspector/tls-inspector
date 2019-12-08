import UIKit
import CertificateKit

// swiftlint:disable identifier_name
var CERTIFICATE_CHAIN: CKCertificateChain?
var SERVER_INFO: CKServerInfo?
var CURRENT_CERTIFICATE: Int = 0
var CHANGE_CERTIFICATE_NOTIFICATION = NSNotification.Name(rawValue: "🔐")
var SPLIT_VIEW_CONTROLLER: UISplitViewController?
// swiftlint:enable identifier_name
