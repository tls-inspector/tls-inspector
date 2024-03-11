import UIKit
import StoreKit
import MessageUI
import CertificateKit

class AppLinks : NSObject, SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate {
    // App Store ID number for TLS Inspector. Not secret.
    public static let tlsInspectorAppId = "1100539810"
    // App Store ID number for DNS Inspector. Not secret.
    public static let dnsInspectorAppId = "6470965982"
    // Settings key to track the number of times the application has been launched
    private let appLaunchKey = "__APP_LAUNCH_TIMES"
    // Settings key to track if the user has been prompted to rate the app
    private let appLaunchRateKey = "__APP_LAUNCH_RATE"
    private let appName = "TLS Inspector"
    private let appEmail = "'TLS Inspector' <hello@tlsinspector.com>"
    // Used to track which app store views come from the app v.s. which come from our website
    // not used to track you or your device.
    private let appCampaignToken = "acid-burn"
    private var dimissedBlock: (() -> Void)?
    private var shouldPurgeLogs = false
    public static var current = AppLinks()

    public func showAppStoreIn(_ viewController: UIViewController, appId: String, dismissed: (() -> Void)?) {
        let productViewController = SKStoreProductViewController()
        productViewController.delegate = self
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier: appId,
            SKStoreProductParameterCampaignToken: appCampaignToken,
        ]
        productViewController.loadProduct(withParameters: parameters, completionBlock: nil)
        viewController.present(productViewController, animated: true, completion: nil)
        self.dimissedBlock = dismissed
    }

    internal func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true) {
            self.dimissedBlock?()
        }
    }

    @available(iOS 10.3, *)
    public func appLaunchRate() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: appLaunchRateKey) {
            var launchTimes: Int = 1
            if let times = defaults.object(forKey: appLaunchKey) as? NSNumber {
                launchTimes = times.intValue
            }
            if launchTimes > 2 {
                SKStoreReviewController.requestReview()
                defaults.set(true, forKey: appLaunchRateKey)
            }
            launchTimes += 1
            defaults.set(launchTimes, forKey: appLaunchKey)
        }
    }

    public func showEmailCompose(viewController: UIViewController, object: SupportType, includeLogs: Bool, dismissed: (() -> Void)?) {
        if !MFMailComposeViewController.canSendMail() {
            return
        }

        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setSubject(appName + " Feedback")
        mailController.setToRecipients([appEmail])
        mailController.setMessageBody(object.body(), isHTML: true)

        if includeLogs {
            self.attachTextFile(actualName: "CertificateKit.log", attachmentName: "TLS Inspector Log.txt", mailController: mailController)
            self.attachTextFile(actualName: "exceptions.log", attachmentName: "Exceptions.txt", mailController: mailController)
            if let fileName = UserOptions.writeToFile() {
                self.attachTextFile(actualName: fileName, attachmentName: "Settings.txt", mailController: mailController)
            }
            self.shouldPurgeLogs = true
        }

        self.dimissedBlock = dismissed
        viewController.present(mailController, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent && self.shouldPurgeLogs {
            CKLogging.sharedInstance().truncateLogs()
            self.shouldPurgeLogs = false
        }

        controller.dismiss(animated: true) {
            self.dimissedBlock?()
        }
    }

    private func attachTextFile(actualName: String, attachmentName: String, mailController: MFMailComposeViewController) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count == 0 {
            LogError("Error getting documents directory")
            return
        }
        let documentsDirectory = URL(fileURLWithPath: paths[0])

        let filePath = documentsDirectory.appendingPathComponent(actualName)
        if !FileManager.default.fileExists(atPath: filePath.path) {
            LogError("Error getting \(filePath)")
            return
        }

        var data: Data?
        do {
            try data = Data(contentsOf: filePath)
        } catch {
            LogError("Error reading log file: \(error.localizedDescription)")
            return
        }

        mailController.addAttachmentData(data ?? Data(), mimeType: "text/plain", fileName: attachmentName)
    }
}
