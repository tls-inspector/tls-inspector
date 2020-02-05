import UIKit
import StoreKit
import MessageUI

class AppLinks : NSObject, SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate {
    private let appLaunchKey = "__APP_LAUNCH_TIMES"
    private let appLaunchRateKey = "__APP_LAUNCH_RATE"
    private let appID = "1100539810"
    private let appName = "TLS Inspector"
    private let appEmail = "'TLS Inspector Project Manager' <hello@tlsinspector.com>"
    private var dimissedBlock: (() -> Void)?
    public static var current = AppLinks()

    public func showAppStore(_ viewController: UIViewController, dismissed: (() -> Void)?) {
        let productViewController = SKStoreProductViewController()
        productViewController.delegate = self
        productViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appID], completionBlock: nil)
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
            self.attachCertificateKitLog(mailController)
            self.attachExceptionLog(mailController)
        }

        self.dimissedBlock = dismissed
        viewController.present(mailController, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            self.dimissedBlock?()
        }
    }

    private func attachCertificateKitLog(_ mailController: MFMailComposeViewController) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsDirectory = URL(string: paths[0]) else {
            return
        }
        let ckLogPath = documentsDirectory.appendingPathComponent("CertificateKit.log")
        if !FileManager.default.fileExists(atPath: ckLogPath.absoluteString) {
            return
        }

        var data: Data?
        do {
            try data = Data(contentsOf: ckLogPath)
        } catch {
            return
        }

        mailController.addAttachmentData(data ?? Data(), mimeType: "text/plain", fileName: "TLS Inspector.log")
    }

    private func attachExceptionLog(_ mailController: MFMailComposeViewController) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsDirectory = URL(string: paths[0]) else {
            return
        }
        let exceptionsLogPath = documentsDirectory.appendingPathComponent("exceptions.log")
        if !FileManager.default.fileExists(atPath: exceptionsLogPath.absoluteString) {
            return
        }

        var data: Data?
        do {
            try data = Data(contentsOf: exceptionsLogPath)
        } catch {
            return
        }

        mailController.addAttachmentData(data ?? Data(), mimeType: "text/plain", fileName: "Exceptions.log")
    }
}
